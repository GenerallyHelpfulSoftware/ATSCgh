//
//  EventInformationTable.m
//  ATSCgh
// The MIT License (MIT)

//  Copyright (c) 2011-2015 Glenn R. Howes

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "EventInformationTable.h"
#import "ContentAdvisoryDescriptor.h"
#import "CaptionServiceDescriptor.h"
#import "LanguageString.h"
#import "AudioStreamDescriptor.h"
#import "ExtendedAudioStreamDescriptor.h"
#import "SystemTimeTable.h"

@interface EventInformationRecord()
// redefinitions so I can assign to them
@property(nonatomic, assign) UInt16 event_id;
@property(nonatomic, assign) NSTimeInterval start_time;
@property(nonatomic, assign) ETMLocation extendedTextLocation;
@property(nonatomic, assign) NSTimeInterval length_in_seconds;
@property(nonatomic, strong) NSArray* titles;
@property(nonatomic, strong) NSArray* descriptors;
@property(nonatomic, readwrite) UInt16 source_id;
@end


@implementation EventInformationRecord

-(NSDate*) startDate
{
    NSDate* result = [SystemTimeTable dateFrom1980:self.start_time];
    return result;
}

-(NSDate*) endDate
{
    NSDate* result = [SystemTimeTable dateFrom1980:self.start_time+self.length_in_seconds];
    return result;
}

-(NSString*) description
{
    NSTimeZone* myTimeZone = [NSTimeZone defaultTimeZone];
    NSInteger secondsOffGMT = [myTimeZone secondsFromGMT];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    NSString* startDateString = [df stringFromDate:[[self startDate] dateByAddingTimeInterval:secondsOffGMT]];
    NSString* endDateString = [df stringFromDate:[[self endDate] dateByAddingTimeInterval:secondsOffGMT]];
    NSString* result = [NSString stringWithFormat:@"Event Information Table Event ID:%d\nSource ID:%d\nStart Date:%@\nEnd Date:%@ \n Titles: \n %@ \n Descriptors: \n %@", self.event_id, self.source_id, startDateString, endDateString, self.titles.description, self.descriptors.description];
    return result;
}

-(NSArray<LanguageString*>*) titleArray
{
    if(self.titles != nil)
    {
        return self.titles;
    }
    else
    {
        return [NSArray new];
    }
}
@end

@implementation EventInformationTable

-(NSString*) uniqueKey
{
    NSString* superKey = [super uniqueKey];
    NSString* result = [NSString stringWithFormat:@"%@:%hd", superKey, self.source_id];
    
    return result;
}

-(instancetype)initWithTableHeader:(TableHeader)aHeader packetHeader:(PacketHeader)packetHeader rawData:(const unsigned char*) streamData
{
    if(nil != (self = [super initWithTableHeader:aHeader packetHeader:packetHeader rawData:streamData]))
    {
        _source_id = streamData[3] << 8 | streamData[4];
        unsigned char num_events_in_section = streamData[9];
        size_t byteOffset = 10;
        NSMutableArray* mutableRecords = [[NSMutableArray alloc] initWithCapacity:num_events_in_section];
        for(unsigned char eventIndex = 0; eventIndex< num_events_in_section; eventIndex++)
        {
            EventInformationRecord* aRecord = [EventInformationRecord new];
            [mutableRecords addObject:aRecord];
            aRecord.event_id = (63 & streamData[byteOffset++]) << 8 | streamData[byteOffset++];
            
            UInt32 secondsSince1980 = streamData[byteOffset] << 24 | streamData[byteOffset+1] << 16
            | streamData[byteOffset+2] << 8 | streamData[byteOffset+3];
            aRecord.start_time = secondsSince1980;
            byteOffset += 4;
            
            aRecord.extendedTextLocation = (streamData[byteOffset] >> 4) & 3;
            UInt32 lengthInSeconds = (streamData[byteOffset] & 0xF) << 16
            | streamData[byteOffset+1] << 8 | streamData[byteOffset+2];
            byteOffset += 3;
            aRecord.length_in_seconds = lengthInSeconds;
            
            
            unsigned char title_length = streamData[byteOffset++];
            if(title_length)
            { // if there are any titles, get their strings
                
                aRecord.titles = [LanguageString extractFromRawData:&streamData[byteOffset]];
                byteOffset += title_length;
            }
            else
            {
                aRecord.titles = [NSArray new];
            }
            UInt16 descriptors_length = (15 & streamData[byteOffset]) << 8 | streamData[byteOffset+1];
            byteOffset += 2;
            
            if(descriptors_length)
            {
                NSMutableArray* descriptors = [[NSMutableArray alloc] init];
                size_t descriptorsByteOffset = byteOffset;
                byteOffset += descriptors_length;
                while(descriptorsByteOffset <= byteOffset)
                {
                    unsigned char descriptor_tag = streamData[descriptorsByteOffset];
                    unsigned char descriptor_length = streamData[descriptorsByteOffset+1];
                    if(descriptors_length == 0) break; // avoid malformed descriptors
                    switch(descriptor_tag)
                    {
                        case 0x81: // Audio Descriptor
                        {
                            AudioStreamDescriptor* anAudioStreamDescriptor = [[AudioStreamDescriptor alloc] initWithRawData:&streamData[descriptorsByteOffset]];
                            [descriptors addObject:anAudioStreamDescriptor];
                        }
                        break;
                        case 0xCC: // E-AC-3 Audio Descriptor
                        {
                            ExtendedAudioStreamDescriptor* anExtendedAudioStreamDescriptor = [[ExtendedAudioStreamDescriptor alloc] initWithRawData:&streamData[descriptorsByteOffset]];
                            [descriptors addObject:anExtendedAudioStreamDescriptor];
                        }
                        break;
                        case 0x87: // Content Advisory
                        {
                            ContentAdvisoryDescriptor* contentAdvisoryDescriptor = [[ContentAdvisoryDescriptor alloc] initWithRawData:&streamData[descriptorsByteOffset]];
                            [descriptors addObject:contentAdvisoryDescriptor];
                        }
                        break;
                        case 0x86: // Caption service
                        {
                            CaptionServiceDescriptor* captionServiceDescriptor = [[CaptionServiceDescriptor alloc] initWithRawData:&streamData[descriptorsByteOffset]];
                            [descriptors addObject:captionServiceDescriptor];
                        }
                        break;
                    }
                    descriptorsByteOffset+=2; // jump over tag and length bytes
                    descriptorsByteOffset += descriptor_length; // jump over individual descriptor
                }
                aRecord.descriptors = [descriptors copy];
            }
            
        }
        _records = [mutableRecords copy];
    }
    return self;
}

-(NSString*)description
{
    NSString* result = [NSString stringWithFormat:@"Source ID:%d \n Records: \n %@ \n", self.source_id, self.records.description];
    return result;
}
@end

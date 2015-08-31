//
//  ExtendedTextTable.m
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ExtendedTextTable.h"
#import "LanguageString.h"

@interface ExtendedTextTable ()
@property(nonatomic, readwrite) UInt16 source_id;
@property(nonatomic, readwrite) UInt16 event_id;
@property(nonatomic, strong) NSArray* strings; // LanguageStrings

@end

@implementation ExtendedTextTable

-(NSString*)description
{
    NSString* result = [NSString stringWithFormat:@"Extended Text Table Source ID:%d, Event ID:%d\n\tStrings:\n%@\n", self.source_id, self.event_id, self.strings.description];
    return result;
}

-(NSString*) uniqueKey
{
    NSString* superKey = [super uniqueKey];
    NSString* result = [NSString stringWithFormat:@"%@:%hd", superKey, self.source_id];
    return result;
}

-(id)initWithTableHeader:(TableHeader)aHeader packetHeader:(PacketHeader)packetHeader rawData:(const unsigned char*) streamData
{
    if(nil != (self = [super initWithTableHeader:aHeader packetHeader:packetHeader rawData:streamData]))
    {
        unsigned char byte9 = streamData[9];
        unsigned char byte10 = streamData[10];
        
        _source_id = byte9<< 8 | byte10;
        
        unsigned char byte11 = streamData[11];
        unsigned char byte12 = streamData[12];
        _event_id = (byte11 << 6) | (byte12 >> 2);
        
        _strings = [LanguageString extractFromRawData:&streamData[13]];
    }
    return self;
}
@end



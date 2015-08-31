//
//  LanguageString.m
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "LanguageString.h"
#import "NSString+DigitalTV.h"

@implementation LanguageString

+(NSString*) bestMatchFromSet:(NSSet*)setOfLanguageStrings
{
    NSString* result = nil;
    if(setOfLanguageStrings.count)
    {
        LanguageString* bestMatch = [setOfLanguageStrings anyObject]; //TODO fix this
        NSAssert([bestMatch isKindOfClass:[LanguageString class]], @"Expected a Language string");
        result = bestMatch.string;
    }
    return result;
}

+(NSArray*)extractFromRawData:(const unsigned char*)streamData
{
    size_t byteOffset = 0;
    unsigned char number_strings = streamData[byteOffset++];
    NSMutableArray* mutableResult = [[NSMutableArray alloc] initWithCapacity:number_strings];
    for(unsigned char stringIndex = 0; stringIndex < number_strings; stringIndex++)
    {
        NSString* languageCode = [[NSString alloc] initWithBytes:&streamData[byteOffset] length:3 encoding:NSASCIIStringEncoding]; // like 'eng' for English
        byteOffset += 3;
        unsigned char numberOfSegments = streamData[byteOffset++];
        
        NSMutableString* compositeString = [[NSMutableString alloc] init];
        
        for(unsigned char segmentIndex = 0; segmentIndex < numberOfSegments; segmentIndex++)
        {// each segment can be compressed and character encoded in different ways (probably the reason for segments)
            unsigned char compression_type = streamData[byteOffset++];
            unsigned char mode = streamData[byteOffset++];
            unsigned char number_bytes = streamData[byteOffset++];
            NSString* segmentString = [NSString stringWithCompression:(ATSCCompressionType)compression_type mode:mode data:&streamData[byteOffset] byteCount:number_bytes];
            if(segmentString.length)
            {
                [compositeString appendString:segmentString];
            }
            byteOffset += number_bytes;
        }
        LanguageString* aString = [[LanguageString alloc] initWithLanguageCode:languageCode andString:[compositeString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        [mutableResult addObject:aString];
    }
    return [mutableResult copy];
}

-(id) initWithLanguageCode:(NSString*)languageCode andString:(NSString*)string
{
    if(nil != (self = [super init]))
    {
        _languageCode = languageCode;
        _string = string;
    }
    return self;
}

-(NSString*)description
{
    NSString* result = [NSString stringWithFormat:@"%@:'%@'", self.languageCode, self.string];
    return result;
}

@end
//
//  LanguageString.m
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

-(instancetype) initWithLanguageCode:(NSString*)languageCode andString:(NSString*)string
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
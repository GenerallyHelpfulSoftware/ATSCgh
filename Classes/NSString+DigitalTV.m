//
//  NSString+DigitalTV.m
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
//  Created by Glenn Howes on 1/8/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "NSString+DigitalTV.h"
#import "NSData+DigitalTV.h"
@implementation NSString (DigitalTV)
+(NSString*) stringFromData:(NSData*)stringData withFirstByte:(unsigned char)firstByte
{
    NSMutableData* extendedData = [NSMutableData dataWithLength:stringData.length*2];
    unsigned char* destination = [extendedData mutableBytes];
    const unsigned char* source = [stringData bytes];
    NSUInteger length = stringData.length;
    for(NSUInteger index = 0; index < length; index++)
    {// build up an array of 16 bit unicode characters (not UTF-16)
#if __BIG_ENDIAN__
        *destination++ = firstByte;
        *destination++ = *source++;
#else
        *destination++ = *source++;
        *destination++ = firstByte;
#endif
    }
    
    NSString* result = [NSString stringWithCharacters:extendedData.bytes length:stringData.length];
    return result;
}
+(NSString*) stringWithCompression:(ATSCCompressionType)compressionType mode:(unsigned char)mode data:(const unsigned char*) dataPtr byteCount:(NSUInteger)byteCount
{
    NSString* result = nil;
    NSData* theData = [NSData dataWithBytes:dataPtr length:byteCount];
    switch(compressionType)
    {
        case kNoTextCompression:
        {
        }
        break;
        case kHuffmanTableC4andC5Compression:
        {
            theData = [theData dataAfterUncompressionUsingTablesC5];
        }
        break;
        case kHuffmanTableC6andC7Compression:
        {
            theData = [theData dataAfterUncompressionUsingTablesC7];
        }
        break;
        default:
        {
            theData = nil;
        }
        break;
    }
    if(theData.length)
    {
        switch(mode)
        {
            case kNamedModeStandardCompressionSchemeForUnicode_SCSU:
            {
                result = nil;
            }
            break;
            case kNamedModeUTF16:
            {
                result =  [[NSString alloc] initWithData:theData encoding:NSUTF16StringEncoding];
            }
            break;
            default:
            {
                if((mode >= 0x00 && mode <= 0x06) || (mode >= 0x09 && mode <= 0x10)
                   || (mode >= 0x20 && mode <= 0x27)
                   || (mode >= 0x30 && mode <= 0x33))
                {
                    result = [NSString stringFromData:theData withFirstByte:mode];
                }
                else if(mode == 0x40 || mode == 0x41)
                {// Taiwan
                }
                else if(mode == 0x48)
                {// South Korea
                }
            }
            break;

        }
    }
    
    return [result copy];
}
@end

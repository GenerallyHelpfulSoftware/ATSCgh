//
//  NSString+DigitalTV.h
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

#if defined(__has_feature) && __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

enum
{
    kNamedModeLatin1 = 0x00,
    kNamedModeStandardCompressionSchemeForUnicode_SCSU = 0x3E,
    kNamedModeUTF16 = 0x3F
    
    // if a mode is not in this list and in certain ranges less than 0x3F
    // the mode will be used as the first byte of a 16 bit unicode character
    // while the second byte will be from the dat
};

typedef enum ATSCCompressionType
{
    kNoTextCompression = 0x00,
    kHuffmanTableC4andC5Compression = 0x01,
    kHuffmanTableC6andC7Compression = 0x02,
    
    kUnknownCompressionScheme = 0xFF // actually anything that isn't the first 2
}ATSCCompressionType;


NS_ASSUME_NONNULL_BEGIN

@interface NSString (DigitalTV)
+(nullable NSString*) stringWithCompression:(ATSCCompressionType)compressionType mode:(unsigned char)mode data:(const unsigned char*) dataPtr byteCount:(NSUInteger)byteCount;
+(nullable NSString*) stringFromData:(NSData*)stringData withFirstByte:(unsigned char) firstByte;
@end

NS_ASSUME_NONNULL_END

//
//  NSString+DigitalTV.h
//  Signal GH
//
//  Created by Glenn Howes on 1/8/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>

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


@interface NSString (DigitalTV)
+(NSString*) stringWithCompression:(ATSCCompressionType)compressionType mode:(unsigned char)mode data:(const unsigned char*) dataPtr byteCount:(NSUInteger)byteCount;
+(NSString*) stringFromData:(NSData*)stringData withFirstByte:(unsigned char) firstByte;
@end

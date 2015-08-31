//
//  AudioStreamDescriptor.m
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

#import "AudioStreamDescriptor.h"

@implementation AudioStreamDescriptor

+(unsigned short) bitRateInKilobitsPerSecondForCode:(unsigned char)code
{
    unsigned short result = 0;
    switch (code & 31) {
        case 0:
            result = 32;
        break;
        case 1:
            result = 40;
        break;
        case 2:
            result = 48;
        break;
        case 3:
            result = 56;
        break;
        case 4:
            result = 64;
        break;
        case 5:
            result = 80;
        break;
        case 6:
            result = 96;
        break;
        case 7:
            result = 112;
        break;
        case 8:
            result = 128;
        break;
        case 9:
            result = 160;
        break;
        case 10:
            result = 192;
        break;
        case 11:
            result = 224;
        break;
        case 12:
            result = 256;
        break;
        case 13:
            result = 320;
        break;
        case 14:
            result = 384;
        break;
        case 15:
            result = 448;
        break;
        case 16:
            result = 512;
        break;
        case 17:
            result = 576;
        break;
        case 18:
            result = 640;
        break;
    }
    return result;
}

-(id) initWithRawData:(const unsigned char*)streamData
{
    if(nil != (self = [super initWithRawData:streamData]))
    {
        NSAssert(streamData[0] == 0x81, @"Expected an 0x81 at beginning of an Audio Stream Descriptor");
        unsigned char byte2 = streamData[2];
        _sampleRate = (SampleRateEnumeration)byte2>>4;
        _bsid = byte2 & 31;
        unsigned char byte3 = streamData[3];
        _bitRateInKilobitsPerSecond = [AudioStreamDescriptor bitRateInKilobitsPerSecondForCode:byte3>>2];
        _bitRateIsExact = (byte3 >>7) == 0;
        _bitRateIsUpperLimit = !_bitRateIsExact;
        _surroundMode = (SurroundModeEnumeration) byte3 & 3;
        unsigned char byte4 = streamData[4];
        _bsmod = byte4 >> 5;
        _channelSetup = (ChannelSetupEnumeration) (byte4 >> 1) & 0xF;
        _fullService = byte4 & 1;
        
        // jump over deprecated langcod (5)
        NSUInteger byteOffset = 6;
        if(_channelSetup == 0)
            byteOffset++; // jump over deprecated langcod2
        if(_bsmod <2)
        {
            _mainID = streamData[byteOffset]>>5;
            _priority = (streamData[byteOffset]>>3) & 3;
            byteOffset++;
        }
        else
        {
            byteOffset++; // jumping over asvcflags
        }
        unsigned char textlen = streamData[byteOffset] >> 1;
        BOOL isLatin1Text = streamData[byteOffset] & 1;
        byteOffset++;
        if(textlen)
        {
            if(isLatin1Text)
            {
                _textDescription = [[NSString alloc] initWithBytes:&streamData[byteOffset] length:textlen encoding:NSISOLatin1StringEncoding];
            }
            else
            {
                _textDescription = [[NSString alloc] initWithCharacters:(const unichar *)&streamData[byteOffset] length:textlen/2];
            }
            byteOffset += textlen;
        }
        
        BOOL hasLanguageField = streamData[byteOffset] >> 7;
        BOOL hasLanguageField2 = (streamData[byteOffset] >> 6) & 1;
        byteOffset++;
        if(hasLanguageField)
        {
            _language = [[NSString alloc] initWithBytes:&streamData[byteOffset] length:3 encoding:NSASCIIStringEncoding];
            byteOffset += 3;
        }
        if(hasLanguageField2)
        {// 'right' channel language in case of dual mono
            _secondChannelLanguage = [[NSString alloc] initWithBytes:&streamData[byteOffset] length:3 encoding:NSASCIIStringEncoding];
        }
        
    }
    return self;
}

@end

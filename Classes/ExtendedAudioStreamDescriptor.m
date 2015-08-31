//
//  ExtendedAudioStreamDescriptor.m
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ExtendedAudioStreamDescriptor.h"

@interface ExtendedAudioSubstream()
@property(nonatomic, strong) NSString*               language;
@property(nonatomic, assign) AudioServiceType        serviceType;
@property(nonatomic, assign) short                    index;
@property(nonatomic, assign) BOOL                       substream_priority;
@property(nonatomic, assign) SubstreamChannelSetup    channelSetup;

@end


@implementation ExtendedAudioSubstream
-(id) initWithConfigurationByte:(unsigned char)aByte
{
    if(nil != (self = [super init]))
    {
        _substream_priority = (aByte >> 6) & 1;
        switch((aByte>>3)&7)
        {
            case 0:
            case 6:
            {
                _serviceType = kUnknownAudioServiceType;
            }
                break;
            case 1:
            {
                _serviceType = kMusicAndEffectsAudioServiceType;
            }
                break;
            case 2:
            {
                _serviceType = kVisuallyImpairedAudioServiceType;
            }
            case 3:
            {
                _serviceType = kHearingImpairedAudioServiceType;
            }
                break;
            case 4:
            {
                _serviceType = kDialogueAudioServiceType;
            }
                break;
            case 5:
            {
                _serviceType = kCommentaryAudioServiceType;
            }
                break;
            case 7:
            {
                _serviceType = kVoiceOverAudioServiceType;
            }
                break;
        }
        switch (aByte & 7)
        {
            case 0:
            {
                _channelSetup = kSubstreamMonoChannelSetup;
            }
                break;
            case 2:
            {
                _channelSetup = kSubstreamStereoChannelSetup;
            }
                break;
            case 3:
            {
                _channelSetup = kSubstreamDolbyStereoChannelSetup;
            }
                break;
            case 4:
            {
                _channelSetup = kSubstreamMultiChannelSetup;
            }
                break;
            default:
            {
                _channelSetup = kSubstreamUnknownChannelSetup;
            }
                break;
        }
    }
    return self;
}
@end

@implementation ExtendedAudioStreamDescriptor
-(id) initWithRawData:(const unsigned char*)streamData
{
    if(nil != (self = [super initWithRawData:streamData]))
    {
        NSAssert(streamData[0] == 0xCC, @"Expected an 0x81 at beginning of an Audio Stream Descriptor");
        unsigned char byte2 = streamData[2];
        BOOL bsid_flag = (byte2 >> 6) & 1;
        BOOL mainid_flag = (byte2 >> 5) & 1;
        BOOL asvc_flag = (byte2 >> 4) & 1;
        //  BOOL mixinfoexists = (byte2 >> 3) & 1;
        BOOL substream1_flag = (byte2 >> 2) & 1;
        BOOL substream2_flag = (byte2 >> 1) & 1;
        BOOL substream3_flag = (byte2 & 1);
        unsigned char byte3 = streamData[3];
        BOOL full_service_flag = (byte3 >> 6) & 1;
        NSMutableArray* mutableSubstreams = [[NSMutableArray alloc] initWithCapacity:3];
        ExtendedAudioSubstream* subStream1 = nil;
        ExtendedAudioSubstream* subStream2 = nil;
        ExtendedAudioSubstream* subStream3 = nil;
        
        _serviceType = (byte3 >> 3) & 7;
        if(_serviceType == kVoiceOverAudioServiceType && full_service_flag)
        {
            _serviceType = kKaroakeAudioServiceType;
        }
        _channelSetup = byte3 & 7;
        
        unsigned char byte4 = streamData[4];
        
        BOOL hasLanguageField = byte4 >> 7;
        BOOL hasLanguageField2 = (byte4 >> 6) & 1;
        if(bsid_flag)
        {
            _bsid = byte4 & 31;
        }
        
        NSUInteger byteOffset = 5;
        if(mainid_flag)
        {
            _priority = (streamData[byteOffset] >> 4) & 3;
            _mainID = streamData[byteOffset++] & 7;
        }
        if(asvc_flag)
        {
            _asvc = streamData[byteOffset++];
        }
        if(substream1_flag)
        {
            subStream1 = [[ExtendedAudioSubstream alloc] initWithConfigurationByte:streamData[byteOffset++]];
            subStream1.index = 1;
            [mutableSubstreams addObject:subStream1];
        }
        
        if(substream2_flag)
        {
            subStream2 = [[ExtendedAudioSubstream alloc] initWithConfigurationByte:streamData[byteOffset++]];
            subStream2.index = 2;
            [mutableSubstreams addObject:subStream2];
        }
        if(substream3_flag)
        {
            subStream3 = [[ExtendedAudioSubstream alloc] initWithConfigurationByte:streamData[byteOffset++]];
            subStream3.index = 3;
            [mutableSubstreams addObject:subStream3];
        }
        
        if(hasLanguageField)
        {
            _language = [[NSString alloc] initWithBytes:&streamData[byteOffset] length:3 encoding:NSASCIIStringEncoding];
            byteOffset += 3;
        }
        if(hasLanguageField2)
        {// 'right' channel language in case of dual mono
            _secondChannelLanguage = [[NSString alloc] initWithBytes:&streamData[byteOffset] length:3 encoding:NSASCIIStringEncoding];
            byteOffset += 3;
        }
        if(substream1_flag)
        {
            subStream1.language = [[NSString alloc] initWithBytes:&streamData[byteOffset] length:3 encoding:NSASCIIStringEncoding];
            byteOffset += 3;
        }
        if(substream2_flag)
        {
            subStream2.language = [[NSString alloc] initWithBytes:&streamData[byteOffset] length:3 encoding:NSASCIIStringEncoding];
            byteOffset += 3;
        }
        if(substream3_flag)
        {
            subStream3.language = [[NSString alloc] initWithBytes:&streamData[byteOffset] length:3 encoding:NSASCIIStringEncoding];
           // byteOffset += 3;
        }
        
        _substreams = [mutableSubstreams copy];
    }
    return self;
}
@end
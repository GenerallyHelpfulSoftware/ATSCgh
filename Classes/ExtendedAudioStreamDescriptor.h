//
//  ExtendedAudioStreamDescriptor.h
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ContentDescriptor.h"
#import "AudioStreamDescriptor.h"

typedef enum  ExtendedChannelSetupEnumeration
{
    kMonoChannelSetup,
    kOnePlusOneChannelSetup,
    kStereoChannelSetup,
    kMultiChannelSetup,
    kMultiChannelSurroundSetup,
    kReservedChannelSetup1,
    kReservedChannelSetup2
}ExtendedChannelSetupEnumeration;

typedef enum AudioServiceType
{
    kCompleteMainAudioServiceType = 0,
    kMusicAndEffectsAudioServiceType,
    kVisuallyImpairedAudioServiceType,
    kHearingImpairedAudioServiceType,
    kDialogueAudioServiceType,
    kCommentaryAudioServiceType,
    kEmergencyAudioServiceType,
    kVoiceOverAudioServiceType,
    
    kKaroakeAudioServiceType,
    kUnknownAudioServiceType
}AudioServiceType;

typedef enum SubstreamChannelSetup
{
    kSubstreamMonoChannelSetup,
    kSubstreamStereoChannelSetup,
    kSubstreamDolbyStereoChannelSetup,
    kSubstreamMultiChannelSetup,
    kSubstreamUnknownChannelSetup
}SubstreamChannelSetup;




@interface ExtendedAudioSubstream : NSObject
@property(nonatomic, readonly) short                    index; // 1, 2 or 3
@property(nonatomic, readonly) NSString*                language;
@property(nonatomic, readonly) AudioServiceType serviceType;
@property(nonatomic, readonly) BOOL                 substream_priority;
@property(nonatomic, readonly) SubstreamChannelSetup    channelSetup;

@end

@interface ExtendedAudioStreamDescriptor : ContentDescriptor //tag 0xCC
@property(nonatomic, readonly) AudioServiceType serviceType;
@property(nonatomic, readonly) ExtendedChannelSetupEnumeration channelSetup;
@property(nonatomic, readonly) BOOL     fullService;
@property(nonatomic, readonly) unsigned char          bsid;
@property(nonatomic, readonly) AudioChannelPriority     priority;
@property(nonatomic, readonly) NSString*                language;
@property(nonatomic, readonly) NSString*                secondChannelLanguage;
@property(nonatomic, readonly) unsigned char            mainID;
@property(nonatomic, readonly) NSArray* substreams;//up to 3
@property(nonatomic, readonly) unsigned char            asvc; // bit field indicating which main services this non-main service is associated with (bit 7 on means it's associated with main service 7, etc)
@end
//
//  AudioStreamDescriptor.h
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

#import "ContentDescriptor.h"

typedef enum SampleRateEnumeration
{
    k48KHzSampleRate, //000
    k44Dot1SampelRate, //001
    k32SampleRate,//010
    kReservedSampleRate, // 011
    k48Or44Dot1SampleRate, //100
    k48Or32SampleRate, //101
    k44Dot1Or32SampleRate, //110
    k48Or44Dot1Or32SampleRate //111
}SampleRateEnumeration;


typedef enum SurroundModeEnumeration
{
    kNoSurroundMode,
    kNotDolbySurroundMode,
    kDolbySurroundMode,
    kReservedSurroundMode
}SurroundModeEnumeration;

typedef enum ChannelSetupEnumeration
{
    kOnePlusOneChannels = 0, // dual mono, two separate mono channels, possibly in different languages
    kOne_ZeroChannel,
    kTwo_ZeroChannels,
    kThree_ZeroChannels,
    kTwo_OneChannels,
    kThree_OneChannels,
    kTwo_TwoChannels,
    kThree_TwoChannels,
    
    kOneChannel,
    kLessThanOrEqualToTwoChannels,
    kLessThanOrEqualToThreeChannels,
    kLessThanOrEqualToFourChannels,
    kLessThanOrEqualToFiveChannels,
    kLessThanOrEqualToSixChannels,
    kChannelReserved1,
    kChannelReserved2
}ChannelSetupEnumeration;


typedef enum AudioChannelPriority
{
    kAudioChannelPriorityReserved = 0,
    kPrimaryAudioPriority,
    kOtherAudioPriority,
    kUnspecifiedAudioPriority
}AudioChannelPriority;


@interface AudioStreamDescriptor : ContentDescriptor //tag 0x81
@property(nonatomic, readonly) SampleRateEnumeration sampleRate;
@property(nonatomic, readonly) unsigned char            bsid;
@property(nonatomic, readonly) unsigned char            bsmod;
@property(nonatomic, readonly) unsigned short          bitRateInKilobitsPerSecond;
@property(nonatomic, readonly) BOOL                   bitRateIsExact;
@property(nonatomic, readonly) BOOL                   bitRateIsUpperLimit;
@property(nonatomic, readonly) SurroundModeEnumeration  surroundMode;
@property(nonatomic, readonly) ChannelSetupEnumeration  channelSetup;
@property(nonatomic, readonly) BOOL fullService; // as opposed to a more auxillary source
@property(nonatomic, readonly) unsigned char            mainID;
@property(nonatomic, readonly) AudioChannelPriority     priority;
@property(nonatomic, readonly) NSString*                textDescription;
@property(nonatomic, readonly) NSString*                language;
@property(nonatomic, readonly) NSString*                secondChannelLanguage;
@end


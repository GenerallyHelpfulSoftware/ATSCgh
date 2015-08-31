//
//  TerrestrialVirtualChannelTable.m
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "TerrestrialVirtualChannelTable.h"

@interface TerrestrialVirtualChannel()

@end

@implementation TerrestrialVirtualChannel
-(id) initWithRawData:(const unsigned char*) streamData
{
    if(nil != (self = [super init]))
    {
        const unichar* shortNamePtr = (const unichar*)streamData;
        size_t shortNameLength = 0;
        unichar shortNameBuffer[7]; // 7x2Byte unicode in wrong endian for iOS
        for(size_t stringIndex=0; stringIndex < 7; stringIndex++)
        {
            if(*shortNamePtr == 0)
            {
                break;
            }
            else
            { // have to convert the endianess of this string
                shortNameBuffer[stringIndex] = *shortNamePtr >> 8 | *shortNamePtr << 8;
                shortNameLength++;
                shortNamePtr++;
            }
        }
        _short_name = [[NSString alloc] initWithCharacters:shortNameBuffer length:shortNameLength];
        
        unsigned char byte14 = streamData[14];
        unsigned char byte15 = streamData[15];
        unsigned char byte16 = streamData[16];
        _major_channel_number = (byte14 & 15) << 6 | (byte15 >> 2);
        _minor_channel_number = (byte15 & 3) << 8 | byte16;
        _channel_TSID = streamData[22] << 8  | streamData[23];
        _program_number = streamData[24] << 8  | streamData[25];
        unsigned char byte26 = streamData[26];
        unsigned char byte27 = streamData[27];
        
        _hidden = (byte26 >> 4) & 1;
        _hideGuide = ((byte26 >> 1) & 1) && _hidden;
        _service_type = byte27 & 63;
        _source_id = streamData[28] << 8 | streamData[29];
    }
   
    
    return self;
}

@end

@implementation TerrestrialVirtualChannelTable
-(id)initWithTableHeader:(TableHeader)aHeader packetHeader:(PacketHeader)packetHeader rawData:(const unsigned char*) streamData
{
    if(nil != (self = [super initWithTableHeader:aHeader packetHeader:packetHeader rawData:streamData]))
    {
        _transport_stream_id = streamData[3] << 8 | streamData[4];
        unsigned char  numberOfChannels = streamData[9];
        if(numberOfChannels)
        {
            size_t byteOffset = 10;
            
            NSMutableArray* mutableChannels = [[NSMutableArray alloc] initWithCapacity:numberOfChannels];
            for(unsigned char channelIndex = 0; channelIndex < numberOfChannels; channelIndex++)
            {
                const unsigned char* channelData =  streamData+byteOffset;
                TerrestrialVirtualChannel* aChannel = [[TerrestrialVirtualChannel alloc] initWithRawData:channelData];
                
                [mutableChannels addObject:aChannel];
                
                UInt16 descriptorLength = ((channelData[30] & 3) << 8) | channelData[31];
                byteOffset += descriptorLength;
                byteOffset += 32;
            }
            _channels = [mutableChannels copy];
        }
    }
    return self;
}
@end

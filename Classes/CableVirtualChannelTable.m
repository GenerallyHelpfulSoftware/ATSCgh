//
//  CableVirtualChannelTable.m
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "CableVirtualChannelTable.h"

// NOT IMPLEMENTED

@implementation CableVirtualChannelTable
-(id)initWithTableHeader:(TableHeader)aHeader packetHeader:(PacketHeader)packetHeader rawData:(const unsigned char*) streamData
{
    if(nil != (self = [super initWithTableHeader:aHeader packetHeader:packetHeader rawData:streamData]))
    {
        
    }
    return self;
}
@end
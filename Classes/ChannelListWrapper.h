//
//  ChannelListWrapper.h
//  Signal GH
//
//  Created by Glenn Howes on 8/29/15.
//  Copyright © 2015 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum StandardRegion
{
    kRegionUSAnCanada = 0,
    kRegionAustralia,
    kRegionEuropeanUnion,
    kRegionTaiwan,
    
    kNumberOfRegions
} StandardRegion;

@interface ChannelListWrapper : NSObject
@property (nonatomic, readonly) NSInteger numberOfDigitalChannels;
@property(nonatomic, readonly) NSString* standard;
+(NSString*) broadcastStandardForRegion:(StandardRegion)region;
+(ChannelListWrapper*) broadcastListWrapperForRegion:(StandardRegion) region;
+(ChannelListWrapper*) listWrapperForStandard:(NSString*)standard;

-(NSInteger) frequencyForChannel:(NSInteger)channel;
-(NSArray*) allChannels; // NSDictionary

@end



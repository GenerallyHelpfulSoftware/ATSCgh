//
//  TunerSubchannel+TV.h
//  Signal GH
//
//  Created by Glenn Howes on 12/28/13.
//  Copyright (c) 2013 Generally Helpful Software. All rights reserved.
//

@class Tower;
@class Subchannel;
@class TerrestrialVirtualChannel;
@class Network;


@interface TunerSubchannel (TV)
@property(nonatomic, readonly) NSString* userViewableDescription;
@property(nonatomic, readonly) Tower* tower;
@property(nonatomic, readonly) Subchannel* subchannel;
@property(nonatomic, readonly) Network* network;
@property(nonatomic, readonly) NSString* completedSubchannelNumber;
@property(nonatomic, readonly) NSString* completedDescription;


-(void) extractTables:(NSDictionary*)extractedTables withVirtualChannel:(TerrestrialVirtualChannel*) aVirtualChannel;
@end

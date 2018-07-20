//
//  TunerChannel+TV.h
//  Signal GH
//
//  Created by Glenn Howes on 12/28/13.
//  Copyright (c) 2013 Generally Helpful Software. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN
@class Network;
@class Tower;
@class TunerSubchannel;
@class TunerChannel;

@interface TunerChannel (TV)
@property(nonatomic, readonly)  Network* _Nullable   network;
@property(nonatomic, readonly) Tower* _Nullable tower;
@property(nonatomic, readonly) NSString* _Nullable trimmedCallsign;
-(void) extractATSCTables:(NSDictionary*)newATSCTables; // call on managed context queue
-(void) configureFromStandardDescription:(NSDictionary*)description;

-(nullable TunerSubchannel*) subChannelWithMinor:(NSInteger)minorChannel;

-(nullable Network*) networkForSubChannel:(NSInteger)subChannel;


@end
NS_ASSUME_NONNULL_END

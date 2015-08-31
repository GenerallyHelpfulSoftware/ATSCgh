//
//  TunerChannel+TV.h
//  Signal GH
//
//  Created by Glenn Howes on 12/28/13.
//  Copyright (c) 2013 Generally Helpful Software. All rights reserved.
//

#import "TunerChannel.h"
#import "BroadcasterModel.h"
#import "TVBroadcaster.h"

@interface TunerChannel (TV)
@property(nonatomic, readonly) Network* network;
@property(nonatomic, readonly) Tower* tower;
@property(nonatomic, readonly) NSString* trimmedCallsign;
-(void) extractATSCTables:(NSDictionary*)newATSCTables; // call on managed context queue
-(void) configureFromStandardDescription:(NSDictionary*)description;
@end

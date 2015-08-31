//
//  TunerChannel.h
//  Signal GH
//
//  Created by Glenn Howes on 4/7/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Rating, TunerSubchannel;

@interface TunerChannel : NSManagedObject

@property (nonatomic, retain) NSString * callsign;
@property (nonatomic, retain) NSNumber * frequency;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * standardsTable;
@property (nonatomic, retain) NSNumber * utcOffset;
@property (nonatomic, retain) NSNumber * virtualMajorChannelNumber;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSNumber * seen;
@property (nonatomic, retain) NSSet *ratings;
@property (nonatomic, retain) NSSet *subchannels;
@end

@interface TunerChannel (CoreDataGeneratedAccessors)

- (void)addRatingsObject:(Rating *)value;
- (void)removeRatingsObject:(Rating *)value;
- (void)addRatings:(NSSet *)values;
- (void)removeRatings:(NSSet *)values;

- (void)addSubchannelsObject:(TunerSubchannel *)value;
- (void)removeSubchannelsObject:(TunerSubchannel *)value;
- (void)addSubchannels:(NSSet *)values;
- (void)removeSubchannels:(NSSet *)values;

@end

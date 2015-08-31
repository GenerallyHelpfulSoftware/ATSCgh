//
//  TunerSubchannel.h
//  Signal GH
//
//  Created by Glenn Howes on 3/1/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ScheduledShow, TunerChannel;

@interface TunerSubchannel : NSManagedObject

@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * programName;
@property (nonatomic, retain) NSNumber * virtualMajorChannelNumber;
@property (nonatomic, retain) NSNumber * virtualMinorChannelNumber;
@property (nonatomic, retain) NSString * userVisibleName;
@property (nonatomic, retain) TunerChannel *channel;
@property (nonatomic, retain) NSSet *shows;
@end

@interface TunerSubchannel (CoreDataGeneratedAccessors)

- (void)addShowsObject:(ScheduledShow *)value;
- (void)removeShowsObject:(ScheduledShow *)value;
- (void)addShows:(NSSet *)values;
- (void)removeShows:(NSSet *)values;

@end

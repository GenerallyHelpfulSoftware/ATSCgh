//
//  ContentAdvisory.h
//  Signal GH
//
//  Created by Glenn Howes on 3/1/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EventRating, RatingDescription, ScheduledShow;

@interface ContentAdvisory : NSManagedObject

@property (nonatomic, retain) NSNumber * rating_region;
@property (nonatomic, retain) NSSet *eventRatings;
@property (nonatomic, retain) NSSet *ratingDescriptions;
@property (nonatomic, retain) ScheduledShow *show;
@end

@interface ContentAdvisory (CoreDataGeneratedAccessors)

- (void)addEventRatingsObject:(EventRating *)value;
- (void)removeEventRatingsObject:(EventRating *)value;
- (void)addEventRatings:(NSSet *)values;
- (void)removeEventRatings:(NSSet *)values;

- (void)addRatingDescriptionsObject:(RatingDescription *)value;
- (void)removeRatingDescriptionsObject:(RatingDescription *)value;
- (void)addRatingDescriptions:(NSSet *)values;
- (void)removeRatingDescriptions:(NSSet *)values;

@end

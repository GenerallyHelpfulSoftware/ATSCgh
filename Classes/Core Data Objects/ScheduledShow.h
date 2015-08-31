//
//  ScheduledShow.h
//  Signal GH
//
//  Created by Glenn Howes on 3/1/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContentAdvisory, ShowDescription, ShowTitle, TunerSubchannel;

@interface ScheduledShow : NSManagedObject

@property (nonatomic, retain) NSString * calendarID;
@property (nonatomic, retain) NSDate * end_time;
@property (nonatomic, retain) NSNumber * event_id;
@property (nonatomic, retain) NSDate * start_time;
@property (nonatomic, retain) NSSet *contentAdvisories;
@property (nonatomic, retain) NSSet *descriptions;
@property (nonatomic, retain) TunerSubchannel *subChannel;
@property (nonatomic, retain) NSSet *titles;
@end

@interface ScheduledShow (CoreDataGeneratedAccessors)

- (void)addContentAdvisoriesObject:(ContentAdvisory *)value;
- (void)removeContentAdvisoriesObject:(ContentAdvisory *)value;
- (void)addContentAdvisories:(NSSet *)values;
- (void)removeContentAdvisories:(NSSet *)values;

- (void)addDescriptionsObject:(ShowDescription *)value;
- (void)removeDescriptionsObject:(ShowDescription *)value;
- (void)addDescriptions:(NSSet *)values;
- (void)removeDescriptions:(NSSet *)values;

- (void)addTitlesObject:(ShowTitle *)value;
- (void)removeTitlesObject:(ShowTitle *)value;
- (void)addTitles:(NSSet *)values;
- (void)removeTitles:(NSSet *)values;

@end

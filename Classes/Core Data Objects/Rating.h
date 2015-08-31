//
//  Rating.h
//  Signal GH
//
//  Created by Glenn Howes on 3/1/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RatingTitle, TunerChannel;

@interface Rating : NSManagedObject

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * isGraduated;
@property (nonatomic, retain) TunerChannel *channel;
@property (nonatomic, retain) NSSet *titles;
@end

@interface Rating (CoreDataGeneratedAccessors)

- (void)addTitlesObject:(RatingTitle *)value;
- (void)removeTitlesObject:(RatingTitle *)value;
- (void)addTitles:(NSSet *)values;
- (void)removeTitles:(NSSet *)values;

@end

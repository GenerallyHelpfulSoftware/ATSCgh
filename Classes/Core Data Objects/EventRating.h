//
//  EventRating.h
//  Signal GH
//
//  Created by Glenn Howes on 3/1/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContentAdvisory;

@interface EventRating : NSManagedObject

@property (nonatomic, retain) NSNumber * ratingIndex;
@property (nonatomic, retain) NSNumber * ratingValue;
@property (nonatomic, retain) ContentAdvisory *advisory;

@end

//
//  EventRating.h
//  Signal GH
//
//  Created by Glenn Howes on 3/1/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#if defined(__has_feature) && __has_feature(modules)
@import Foundation;
@import CoreData;
#else
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#endif
@class ContentAdvisory;

@interface EventRating : NSManagedObject

@property (nonatomic, retain) NSNumber * ratingIndex;
@property (nonatomic, retain) NSNumber * ratingValue;
@property (nonatomic, retain) ContentAdvisory *advisory;

@end

//
//  RatingTitle.h
//  Signal GH
//
//  Created by Glenn Howes on 3/1/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LocalizedString.h"

@class Rating;

@interface RatingTitle : LocalizedString

@property (nonatomic, retain) Rating *rating;

@end
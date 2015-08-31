//
//  Data Model Objects.h
//  Signal GH
//
//  Created by Glenn Howes on 2/4/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LocalizedString.h"

@class ScheduledShow;

@interface Data_Model_Objects : LocalizedString

@property (nonatomic, retain) ScheduledShow *show;

@end

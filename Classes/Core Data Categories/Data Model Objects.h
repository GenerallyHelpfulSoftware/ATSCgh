//
//  Data Model Objects.h
//  Signal GH
//
//  Created by Glenn Howes on 2/4/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//


#import "LocalizedString+CoreDataProperties.h"

@class ScheduledShow;

@interface Data_Model_Objects : LocalizedString

@property (nonatomic, retain) ScheduledShow *show;

@end

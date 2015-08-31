//
//  ContentAdvisory+TV.h
//  Signal GH
//
//  Created by Glenn Howes on 2/24/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ContentAdvisory.h"
@class ContentAdvisoryDescriptor;
@class ScheduledShow;

@interface ContentAdvisory (TV)

-(NSString*) advisoryStringGivenSetOfRatings:(NSSet*)ratings; // Rating object found in TunerChannel set

+(void) extractAdvisoriesFromDescriptors:(ContentAdvisoryDescriptor*)aTable intoShow:(ScheduledShow*)aShow;
+(ContentAdvisory*) retrieveBestMatchFromArrayOfAdvisories:(NSArray*)arrayOfAdvisories;
@end

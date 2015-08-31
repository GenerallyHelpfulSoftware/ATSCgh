//
//  ContentAdvisory+TV.m
//  Signal GH
//
//  Created by Glenn Howes on 2/24/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ContentAdvisory+TV.h"
#import "ContentAdvisoryDescriptor.h"
#import "ScheduledShow+TV.h"
#import "RatingDescription.h"
#import "LanguageString.h"
#import "EventRating.h"
#import "Rating+TV.h"
#import "LocalizedString+TV.h"

@implementation ContentAdvisory (TV)
+(void) extractAdvisoriesFromDescriptors:(ContentAdvisoryDescriptor*)aTable intoShow:(ScheduledShow*)aShow
{
    NSEntityDescription* contentAdvisory = [NSEntityDescription entityForName:@"ContentAdvisory" inManagedObjectContext:aShow.managedObjectContext];
    
    NSEntityDescription* ratingDescriptionEntity = [NSEntityDescription entityForName:@"RatingDescription" inManagedObjectContext:aShow.managedObjectContext];
    
    NSEntityDescription* eventRatingEntity = [NSEntityDescription entityForName:@"EventRating" inManagedObjectContext:aShow.managedObjectContext];
    for(EventRatingRegion* aRegion in aTable.rating_regions)
    {
        ContentAdvisory* anAdvisory = [[ContentAdvisory alloc] initWithEntity:contentAdvisory insertIntoManagedObjectContext:aShow.managedObjectContext];
        anAdvisory.rating_region = [[NSNumber alloc] initWithInt:aRegion.rating_region];
        NSInteger index = 0;
        for(EventRatingDimension* aDimension in aRegion.eventRatingDimensions)
        {
            EventRating* newEventRating = [[EventRating alloc] initWithEntity:eventRatingEntity insertIntoManagedObjectContext:aShow.managedObjectContext];
            
            
            newEventRating.ratingIndex = [NSNumber numberWithInteger:index++];
            newEventRating.ratingValue = [NSNumber numberWithInteger:aDimension.rating_value];
            
            newEventRating.advisory = anAdvisory;
            [anAdvisory addEventRatingsObject:newEventRating];

        }
        
        for(LanguageString* aLanguageString in aRegion.rating_descriptions)
        {
            RatingDescription* newDescription = [[RatingDescription alloc] initWithEntity:ratingDescriptionEntity insertIntoManagedObjectContext:aShow.managedObjectContext];
            newDescription.locale = aLanguageString.languageCode;
            newDescription.text = aLanguageString.string;
            
            newDescription.advisory = anAdvisory;
            [anAdvisory addRatingDescriptionsObject:newDescription];
        }
        
        anAdvisory.show = aShow;
        [aShow addContentAdvisoriesObject:anAdvisory];
    }
}

+(ContentAdvisory*) retrieveBestMatchFromArrayOfAdvisories:(NSArray*)arrayOfAdvisories
{
    ContentAdvisory* result = nil;
    if(arrayOfAdvisories.count) // TODO actually look to see what region to return
    {
        result = [arrayOfAdvisories lastObject];
    }
    return result;
}

-(NSString*) advisoryStringGivenSetOfRatings:(NSSet*)ratings
{
    NSString* result = nil;
    if(self.ratingDescriptions.count)
    {
        result = [LocalizedString bestMatchFromSet:self.ratingDescriptions];
    }
    
    if(self.eventRatings)
    {
        NSArray* sortedRatings = [ratings.allObjects sortedArrayUsingComparator:^NSComparisonResult(Rating* obj1, Rating* obj2) {
            return [obj1.index compare:obj2.index];
        }];
        for(EventRating* anEventRating in self.eventRatings)
        {
            NSInteger whichDimension = anEventRating.ratingIndex.integerValue;
            if(whichDimension < sortedRatings.count)
            {
                Rating* theRating = sortedRatings[whichDimension];
                NSString* theTitle = [LocalizedString bestMatchFromSet:theRating.titles];
                if(theTitle.length)
                {
                    if(result.length)
                    {
                        result = [result stringByAppendingFormat:@" %@", theTitle];
                    }
                    else
                    {
                        result = theTitle;
                    }
                }
                if(theRating.isGraduated && anEventRating.ratingValue != nil)
                {
                    result = [result stringByAppendingFormat:@" (%@)", anEventRating.ratingValue.stringValue];
                }
            }
        }
    }
    return result;
}

@end

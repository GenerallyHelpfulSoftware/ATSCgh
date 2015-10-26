//
//  Rating+TV.m
//  Signal GH
//
//  Created by Glenn Howes on 2/24/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "Rating+TV.h"
#import "RatingRegionTable.h"
#import "LocalizedString+TV.h"
#import "RatingTitle.h"
#import "LanguageString.h"
#import "TunerChannel+TV.h"
@implementation Rating (TV)

+(void) extractRatingsFromRatingTable:(RatingRegionTable*)regionTable forChannel:(TunerChannel*)theChannel
{
    [theChannel.managedObjectContext performBlockAndWait:^{
        NSMutableSet* mutableResult = [[NSMutableSet alloc] initWithCapacity:regionTable.rating_dimensions.count];
        NSInteger index = 0;
        NSEntityDescription* ratingTitleEntity = [NSEntityDescription entityForName:@"RatingTitle" inManagedObjectContext:theChannel.managedObjectContext];
        NSEntityDescription* ratingEntity = [NSEntityDescription entityForName:@"Rating" inManagedObjectContext:theChannel.managedObjectContext];
        for(RatingDimension* aDimension in regionTable.rating_dimensions)
        {
            Rating* aRating =  [[Rating alloc] initWithEntity:ratingEntity insertIntoManagedObjectContext:theChannel.managedObjectContext];
            aRating.index = [NSNumber numberWithInteger:index++];
            aRating.channel = theChannel;
            aRating.isGraduated = [NSNumber numberWithBool:aDimension.isGraduatedScale];
            for(LanguageString* aString in aDimension.names)
            {
                RatingTitle* aTitle = [[RatingTitle alloc] initWithEntity:ratingTitleEntity insertIntoManagedObjectContext:theChannel.managedObjectContext];
                aTitle.locale = aString.languageCode;
                aTitle.text = aString.string;
                aTitle.rating = aRating;
                [aRating addTitlesObject:aTitle];
            }
            [mutableResult addObject:aRating];
        }
        [theChannel setRatings:[mutableResult copy]];
    }];
}

+(void) updateRatings:(NSSet*)ratings fromRatingTable:(RatingRegionTable*)regionTable
{
    NSAssert(ratings.count == regionTable.rating_dimensions.count, @"Expected no change in rating dimension count");
    NSArray* oldRatings = [ratings.allObjects sortedArrayUsingComparator:^NSComparisonResult(Rating* obj1, Rating* obj2) {
        NSComparisonResult result = [obj1.index compare:obj2.index];
        return result;
    }];
    
    int16_t index = 0;
    
    for(RatingDimension* aDimension in regionTable.rating_dimensions)
    {
        Rating* aRating = oldRatings[index++];
        
        [aRating.managedObjectContext performBlockAndWait:^{
            if(aRating.isGraduated.boolValue != aDimension.isGraduatedScale)
            {
                aRating.isGraduated = [NSNumber numberWithBool:aDimension.isGraduatedScale];
            }
            NSMutableArray* titlesToRemove = nil;
            NSMutableSet* stringsToAdd = [[NSMutableSet alloc] initWithArray:aDimension.names];
            for(RatingTitle* aTitle in aRating.titles)
            {
                NSString* locale = aTitle.locale;
                NSString* text = aTitle.text;
                BOOL foundIt = NO;
                for(LanguageString* aString in aDimension.names)
                {
                    if([locale isEqualToString:aString.languageCode])
                    {
                        foundIt = YES;
                        if(![text isEqualToString:aString.string])
                        {
                            aTitle.text = aString.string;
                        }
                        [stringsToAdd removeObject:aString];
                        break;
                    }
                }
                
                if(!foundIt)
                {
                    if(titlesToRemove == nil)
                    {
                        titlesToRemove = [[NSMutableArray alloc] initWithObjects:aTitle, nil];
                    }
                    else
                    {
                        [titlesToRemove addObject:aTitle];
                    }
                }
            }
            for(RatingTitle* titleToRemove in titlesToRemove)
            {
                [aRating removeTitlesObject:titleToRemove];
            }
            if(stringsToAdd.count)
            {
                NSEntityDescription* ratingTitleEntity = [NSEntityDescription entityForName:@"RatingTitle" inManagedObjectContext:aRating.managedObjectContext];
                for(LanguageString* aLanguageString in stringsToAdd)
                {
                    RatingTitle* newTitle = [[RatingTitle alloc] initWithEntity:ratingTitleEntity insertIntoManagedObjectContext:aRating.managedObjectContext];
                    newTitle.locale = aLanguageString.languageCode;
                    newTitle.text = aLanguageString.string;
                    newTitle.rating = aRating;
                    [aRating addTitlesObject:newTitle];
                }
            
            }
            
        }];
    }
}

@end

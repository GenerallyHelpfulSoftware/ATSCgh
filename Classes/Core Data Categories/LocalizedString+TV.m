//
//  LocalizedString+TV.m
//  Signal GH
//
//  Created by Glenn Howes on 2/17/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "LocalizedString+TV.h"

@implementation LocalizedString (TV)
+(NSString*) bestMatchFromSet:(NSSet*)setOfLanguageStrings
{
    NSString* result = nil;
    NSUInteger countOfStrings = setOfLanguageStrings.count;
    LocalizedString* bestMatch = nil;
    if(countOfStrings == 1)
    {
        bestMatch = [setOfLanguageStrings anyObject]; //TODO fix this
    }
    else if(countOfStrings > 1)
    {
        static NSSet* defaultCodes= nil;
        static dispatch_once_t  done;
        dispatch_once(&done, ^{
            NSLocale* myLocale = [NSLocale currentLocale];
            NSString* languageCode = [myLocale objectForKey:NSLocaleLanguageCode];
            if([languageCode isEqualToString:@"en"])
            {
                defaultCodes = [[NSSet alloc] initWithObjects: @"eng", nil];
            }
            else if([languageCode isEqualToString:@"es"])
            {
                defaultCodes = [[NSSet alloc] initWithObjects: @"spa", nil];
            }
            else if([languageCode isEqualToString:@"fr"])
            {
                defaultCodes = [[NSSet alloc] initWithObjects: @"fra", @"fre", nil];
            }
        });
        
        if(defaultCodes.count)
        {
            for(LocalizedString* aString in setOfLanguageStrings)
            {
                if([defaultCodes containsObject:aString])
                {
                    bestMatch = aString;
                    break;
                }
            }
            if(bestMatch == nil)
            {
                bestMatch = [setOfLanguageStrings anyObject];
            }
        }
        else
        {
            bestMatch = [setOfLanguageStrings anyObject];
        }
        
    }
    result = bestMatch.text;
    return result;
}
@end

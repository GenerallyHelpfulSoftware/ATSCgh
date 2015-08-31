//
//  LocalizedString+TV.h
//  Signal GH
//
//  Created by Glenn Howes on 2/17/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "LocalizedString.h"

@interface LocalizedString (TV)

+(NSString*) bestMatchFromSet:(NSSet*)setOfLanguageStrings;
@end

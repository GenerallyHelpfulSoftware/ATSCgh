//
//  SwiftWorkarounds.m
//  Signal GH
//
//  Created by Glenn Howes on 5/8/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

#import "SwiftWorkarounds.h"

@implementation EventInformationRecord(Workaround)
-(NSArray<LanguageString*>*) workingTitles
{
    if(self.titles != NULL)
    {
        return self.titles;
    }
    else
    {
        return [NSArray new];
    }
}
@end

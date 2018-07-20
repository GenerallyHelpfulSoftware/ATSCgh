//
//  SwiftWorkarounds.h
//  Signal GH
//
//  Created by Glenn Howes on 5/8/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

#ifndef SwiftWorkarounds_h
#define SwiftWorkarounds_h
#import "LanguageString.h"
#import "EventInformationTable.h"
@interface EventInformationRecord(Workaround)
-(NSArray<LanguageString*>*) workingTitles;
@end



#endif /* SwiftWorkarounds_h */

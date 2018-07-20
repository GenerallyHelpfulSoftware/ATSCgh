//
//  RatingValue.h
//  Signal GH
//
//  Created by Glenn Howes on 4/30/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

#ifndef RatingValue_h
#define RatingValue_h

@import Foundation;

@class LanguageString;

@interface RatingValue : NSObject
@property(nonatomic, readonly, nullable) NSArray<LanguageString*> *     abbreviatedValues;
@property(nonatomic, readonly, nullable) NSArray<LanguageString*> *     values;

@end

#endif /* RatingValue_h */

//
//  RatingDimension.h
//  Signal GH
//
//  Created by Glenn Howes on 4/30/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

#ifndef RatingDimension_h
#define RatingDimension_h

@import Foundation;
#import "RatingValue.h"
@class LanguageString;


@interface RatingDimension : NSObject
@property(nonatomic, readonly, nullable) NSArray<LanguageString*> *  names;
@property(nonatomic, readonly) BOOL isGraduatedScale;
@property(nonatomic, readonly, nullable) NSArray<RatingValue*> * values; // RatingValue
@end

#endif /* RatingDimension_h */

//
//  Rating+TV.h
//  Signal GH
//
//  Created by Glenn Howes on 2/24/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "Rating.h"
@class RatingRegionTable;
@class TunerChannel;
@interface Rating (TV)
+(void) updateRatings:(NSSet*)ratings fromRatingTable:(RatingRegionTable*)regionTable;
+(void) extractRatingsFromRatingTable:(RatingRegionTable*)regionTable forChannel:(TunerChannel*)theChannel;
@end

//
//  RatingRegionTable.h
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ATSCTables.h"

@interface RatingValue : NSObject
@property(nonatomic, readonly) NSArray* abbreviatedValues;
@property(nonatomic, readonly) NSArray* values;
@end

@interface RatingDimension : NSObject
@property(nonatomic, readonly) NSArray* names;
@property(nonatomic, readonly) BOOL isGraduatedScale;
@property(nonatomic, readonly) NSArray* values; // RatingValue
@end

@interface RatingRegionTable : ATSCTable
@property(nonatomic, readonly) unsigned char rating_region; // US, Canada, Taiwan...
@property(nonatomic, readonly) NSArray* names;
@property(nonatomic, readonly) NSArray* rating_dimensions;

@end



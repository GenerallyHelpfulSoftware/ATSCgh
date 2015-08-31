//
//  ContentAdvisoryDescriptor.h
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ContentDescriptor.h"


@interface EventRatingRegion : NSObject
@property(nonatomic, readonly) unsigned char rating_region;
@property(nonatomic, readonly) NSArray* rating_descriptions; // LanguageString
@property(nonatomic, readonly) NSArray* eventRatingDimensions; //EventRatingDimension
@end



@interface EventRatingDimension : NSObject
@property(nonatomic, readonly)  unsigned char rating_dimension;
@property(nonatomic, readonly)  unsigned char rating_value;

@end




@interface ContentAdvisoryDescriptor : ContentDescriptor
@property(nonatomic, readonly) NSArray* rating_regions;
@end

//
//  ContentAdvisoryDescriptor.m
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ContentAdvisoryDescriptor.h"
#import "RatingRegionTable.h"
#import "LanguageString.h"

@interface EventRatingRegion ()
@property(nonatomic, assign) unsigned char rating_region;
@property(nonatomic, strong) NSArray* rating_descriptions; // LanguageString
@property(nonatomic, strong) NSArray* eventRatingDimensions; //EventRatingDimension
@end


@interface EventRatingDimension ()
@property(nonatomic, assign)  unsigned char rating_dimension;
@property(nonatomic, assign)  unsigned char rating_value;

@end

@implementation EventRatingDimension
@end


@implementation EventRatingRegion
@end


@implementation ContentAdvisoryDescriptor
-(id) initWithRawData:(const unsigned char*)streamData
{
    if(nil != (self = [super initWithRawData:streamData]))
    {
        NSAssert(streamData[0] == 0x87, @"Expected an 0x87 at beginning of a Content Advisory Descriptor");
      //  unsigned char descriptor_length = streamData[1];
        unsigned char rating_region_count = streamData[2] & 63;
        size_t byteOffset = 3;
        NSMutableArray* rating_regions = [[NSMutableArray alloc] initWithCapacity:rating_region_count];
        for(int ratingIndex = 0; ratingIndex < rating_region_count; ratingIndex++)
        {
            EventRatingRegion* aRegion = [EventRatingRegion new];
            [rating_regions addObject:aRegion];
            aRegion.rating_region = streamData[byteOffset++];
            unsigned char rated_dimensions = streamData[byteOffset++];
            NSMutableArray* dimensions = [[NSMutableArray alloc] initWithCapacity:rated_dimensions];
            for(int i = 0; i < rated_dimensions; i++)
            {
                EventRatingDimension* aDimension = [EventRatingDimension new];
                aDimension.rating_dimension = streamData[byteOffset++];
                aDimension.rating_value = (streamData[byteOffset++]) & 15;
                [dimensions addObject:aDimension];
            }
            aRegion.eventRatingDimensions = [dimensions copy];
            unsigned char rating_description_length = streamData[byteOffset++];
            if(rating_description_length)
            {
                aRegion.rating_descriptions = [LanguageString extractFromRawData:&streamData[byteOffset]];
                byteOffset += rating_description_length;
            }
        }
        _rating_regions = [rating_regions copy];
        
    }
    return self;
}

@end

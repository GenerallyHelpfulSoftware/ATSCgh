//
//  ContentAdvisoryDescriptor.m
//  ATSCgh
// The MIT License (MIT)

//  Copyright (c) 2011-2015 Glenn R. Howes

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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


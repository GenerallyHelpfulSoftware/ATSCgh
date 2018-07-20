//
//  RatingRegionTable.m
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

#import "RatingRegionTable.h"
#import "LanguageString.h"

@interface RatingValue()
@property(nonatomic, strong, nullable) NSArray* abbreviatedValues;
@property(nonatomic, strong, nullable) NSArray* values;
@end

@interface RatingDimension ()
@property(nonatomic, strong, nullable) NSArray* names;
@property(nonatomic, assign) BOOL isGraduatedScale;
@property(nonatomic, strong, nullable) NSArray* values; // RatingValue
@end


@implementation RatingValue
-(NSString*) description
{
    NSString* result = [NSString stringWithFormat:@"Abbreviated Values:\n%@\nValues:\n%@\n", self.abbreviatedValues.description, self.values.description];
    return result;
}

@end

@implementation RatingDimension
-(NSString*)description
{
    NSString* result = [NSString stringWithFormat:@"Is Graduated:%@\nNames:\n%@\nValues:\n%@\n", self.isGraduatedScale?@"YES":@"NO", self.names.description, self.values.description];
    return result;
}
@end

@implementation RatingRegionTable
-(instancetype)initWithTableHeader:(TableHeader)aHeader packetHeader:(PacketHeader)packetHeader rawData:(const unsigned char*) streamData
{
    if(nil != (self = [super initWithTableHeader:aHeader packetHeader:packetHeader rawData:streamData]))
    {
        _rating_region = streamData[4];
        size_t byteOffset = 10;
        unsigned char regionNameLength = streamData[9];
        if(regionNameLength)
        {
            _names = [LanguageString extractFromRawData:&streamData[byteOffset]];
            byteOffset += regionNameLength;
        }
        unsigned char dimensions_defined = streamData[byteOffset++];
        NSMutableArray* dimensions = [[NSMutableArray alloc] initWithCapacity:dimensions_defined];
        for(int dimensionIndex = 0; dimensionIndex < dimensions_defined; dimensionIndex++)
        {
            RatingDimension* aDimension = [RatingDimension new];
            [dimensions addObject:aDimension];
            unsigned char dimension_name_length = streamData[byteOffset++];
            if(dimension_name_length)
            {
                aDimension.names = [LanguageString extractFromRawData:&streamData[byteOffset]];
                byteOffset += dimension_name_length;
            }
            aDimension.isGraduatedScale = (streamData[byteOffset]>>4) & 1;
            unsigned char values_defined = streamData[byteOffset++] & 0xF;
            NSMutableArray* values = [[NSMutableArray alloc] initWithCapacity:values_defined];
            for(int valueIndex = 0; valueIndex < values_defined; valueIndex++)
            {
                RatingValue* aValue = [RatingValue new];
                [values addObject:aValue];
                unsigned char abbrev_rating_value_length = streamData[byteOffset++];
                if(abbrev_rating_value_length)
                {
                    aValue.abbreviatedValues = [LanguageString extractFromRawData:&streamData[byteOffset]];
                    byteOffset += abbrev_rating_value_length;
                }
                unsigned char rating_value_length = streamData[byteOffset++];
                if(rating_value_length)
                {
                    aValue.values =[LanguageString extractFromRawData:&streamData[byteOffset]];
                    byteOffset += rating_value_length;
                }
            }
        }
        _rating_dimensions = [dimensions copy];
        
    }
    return self;
}

-(NSString*)description
{
    NSString* result = [NSString stringWithFormat:@"Rating Region:%d\nNames:\n%@\nDimensions:\n%@\n", self.rating_region, self.names.description, self.rating_dimensions.description];
    return result;
}

@end



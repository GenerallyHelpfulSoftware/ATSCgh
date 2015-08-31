//
//  CaptionServiceDescriptor.m
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "CaptionServiceDescriptor.h"
#import "NSString+DigitalTV.h"


@interface CaptionService ()
@property(nonatomic, strong) NSString* language;
@property(nonatomic, assign) BOOL is708DigitalCCService; // otherwise 608
@property(nonatomic, assign) unsigned char caption_service_number;
@property(nonatomic, assign) BOOL isEasyReader;
@property(nonatomic, assign) BOOL isWideAspectRatio;
@end
@implementation CaptionService
@end

@implementation CaptionServiceDescriptor

-(id) initWithRawData:(const unsigned char*)streamData
{
    if(nil != (self = [super initWithRawData:streamData]))
    {
        NSAssert(streamData[0] == 0x86, @"Expected an 0x86 at beginning of a CaptionServiceDescriptor");
        unsigned char  number_of_services = streamData[2] & 31;
        size_t byteOffset = 3;
        NSMutableArray* services = [[NSMutableArray alloc] initWithCapacity:number_of_services];
        for(int serviceIndex = 0; serviceIndex < number_of_services; serviceIndex++)
        {
            CaptionService* aService = [CaptionService new];
            
            aService.language = [[NSString alloc] initWithBytes:&streamData[byteOffset] length:3 encoding:NSASCIIStringEncoding];
            byteOffset += 3;
            aService.is708DigitalCCService = streamData[byteOffset] >> 7;
            if(aService.is708DigitalCCService)
            {
                aService.caption_service_number = streamData[byteOffset] & 63;
            }
            byteOffset++;
            
            aService.isEasyReader = streamData[byteOffset] >> 7;
            aService.isWideAspectRatio = (streamData[byteOffset++] >> 6 ) & 1;
            byteOffset ++; // jumb over reserved
            
            
            [services addObject:aService];
            
        }
        _services = [services copy];
    }
    return self;
}
@end
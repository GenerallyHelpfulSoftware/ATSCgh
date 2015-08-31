//
//  CaptionServiceDescriptor.h
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ContentDescriptor.h"

@interface CaptionService : NSObject
@property(nonatomic, readonly) NSString* language;
@property(nonatomic, readonly) BOOL is708DigitalCCService; // otherwise 608
@property(nonatomic, readonly) unsigned char caption_service_number;
@property(nonatomic, readonly) BOOL isEasyReader;
@property(nonatomic, readonly) BOOL isWideAspectRatio;
@end


@interface CaptionServiceDescriptor : ContentDescriptor
@property(nonatomic,readonly) NSArray* services; // CaptionService
@end

//
//  ContentDescriptor.h
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContentDescriptor : NSObject
-(id) initWithRawData:(const unsigned char*)streamData;
@end

//
//  TableExtractor.h
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
//  Created by Glenn Howes on 2/7/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//


#if defined(__has_feature) && __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

NS_ASSUME_NONNULL_BEGIN

typedef void (^parsingCallback_t)(NSUInteger endIndex, NSDictionary* __nullable extractors, NSDictionary* __nullable tables);
@interface TableExtractor : NSObject
@property(nonatomic, readonly) NSNumber* pid;
@property(nonatomic, readonly) unsigned char table_id;


+(void) extractTablesFromData:(const unsigned char*)theData ofValidLength:(size_t)validLength withSetOfExtractors:(NSDictionary*)preexisting intoCallback:(parsingCallback_t)callback;
-(instancetype) initWithPID:(NSNumber*)aPid;
-(nullable instancetype) init __attribute__((unavailable("init not available")));

@end

NS_ASSUME_NONNULL_END

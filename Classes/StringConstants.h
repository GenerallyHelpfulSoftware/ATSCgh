//
//  StringConstants.h
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
//  Created by Glenn Howes on 8/30/15.
//  Copyright © 2015 Generally Helpful Software. All rights reserved.
//


#if defined(__has_feature) && __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSString* const kTunerFrequencyTag; // NSNUMBER (integer)
extern NSString* const kRealChannelTag; // NSNUMBER (integer)
extern NSString* const kShowChannelInList; // NSNumber (BOOL)
extern NSString* const kChannelMapStandardTag;
extern NSString* const kProgramsArrayTag; // NSArray of NSDictionaries
extern NSString* const kProgramNameTag;	// NSString
extern NSString* const kProgramNumberTag; // NSNumber
extern NSString* const kProgramVirtualMajorChannelTag; // NSNumber (integer) like the 25 in 25.1
extern NSString* const kProgramVirtualMinorChannelTag; // NSNumber (integer) like the 1 in 25.1



extern NSString* const kAmericanChannelsTag;
extern NSString* const kEuropeanChannelsTag;
extern NSString* const kTaiwanChannelsTag;
extern NSString* const kAustralianChannelsTag;

NS_ASSUME_NONNULL_END

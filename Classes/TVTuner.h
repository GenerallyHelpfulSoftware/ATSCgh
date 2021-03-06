//
//  TVTuner.h
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

@protocol TVTuner;


NS_ASSUME_NONNULL_BEGIN

typedef void (^transaction_callback_t)(NSDictionary*);
typedef void (^simple_callback_t)();


typedef void(^statusTransactionResult_t)(NSDictionary* transaction, NSObject<TVTuner>* _Nullable aTuner);
typedef void(^retrieveTunersForScheduels_t)( NSArray* _Nullable  wrappers);

@protocol TVTuner <NSObject>
@property(nonatomic, readonly) BOOL canReceiveData;
@property(atomic, assign, getter=isScanningSchedule)       BOOL scanningSchedule;
@property (nonatomic, assign) dispatch_source_t      __nullable        pollingSource;
-(nullable const uint8_t*) retrieveDataOfMaximumSize:(size_t) availableSize  returningSizeRetrieved:(size_t*)sizeRetrieved;
-(void) startSettingPIDFilter:(NSString*)pidFilters forTransaction:(NSDictionary*)transaction withCallback:(transaction_callback_t)callback;
-(void) startStoppingStreamingWithTransaction:(NSDictionary*)transaction withCallback:(transaction_callback_t)callback;
-(void) startStreamingWithTransaction:(NSDictionary*)transaction withCallback:(transaction_callback_t)callback;
-(void) startTuningToFrequency:(NSNumber*)newFrequency forTransaction:(NSDictionary*)transaction withCallback:(transaction_callback_t)callback;

-(void) startRetrievingStatus:(statusTransactionResult_t)statusResultCallback;
- (void)addOperationWithBlock:(void (^)(void))block;

@end


void RetrieveTunersForScheduling(retrieveTunersForScheduels_t callback);
BOOL CheckForErrorInTransaction(NSDictionary* transationToCheck);

NS_ASSUME_NONNULL_END

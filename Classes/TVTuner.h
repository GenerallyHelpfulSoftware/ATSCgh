//
//  TVTuner.h
//  Signal GH
//
//  Created by Glenn Howes on 8/30/15.
//  Copyright © 2015 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TVTuner;

typedef void (^transaction_callback_t)(NSDictionary*);
typedef void (^simple_callback_t)();


typedef void(^statusTransactionResult_t)(NSDictionary* transaction, NSObject<TVTuner>* aTuner);
typedef void(^retrieveTunersorScheduels_t)(NSArray* wrappers);

@protocol TVTuner <NSObject>
@property(nonatomic, readonly) BOOL canReceiveData;
@property (nonatomic, assign) dispatch_source_t                 pollingSource;
-(const uint8_t*) retrieveDataOfMaximumSize:(size_t) availableSize  returningSizeRetrieved:(size_t*)sizeRetrieved;
-(void) setPIDFilters:(NSString*)pidIDsToPass withTransaction:(NSDictionary*)transaction withCallback:(transaction_callback_t)callback; // just retrieve the basic tables and no other data
-(void) startSettingPIDFilter:(NSString*)pidFilters forTransaction:(NSDictionary*)transaction withCallback:(transaction_callback_t)callback;
-(void) startStoppingStreamingWithTransaction:(NSDictionary*)transaction withCallback:(transaction_callback_t)callback;
-(void) startStreamingWithTransaction:(NSDictionary*)transaction withCallback:(transaction_callback_t)callback;
-(void) stopStreamingWithTransaction:(NSDictionary*)transaction withCallback:(transaction_callback_t)callback;
-(void) tuneToFrequency:(NSNumber*)newFrequency forTransaction:(NSDictionary*)transaction withCallback:(transaction_callback_t)callback;

-(void)tuneToFrequencyTransaction:(NSDictionary*)transaction withCallback:(transaction_callback_t)callback; // keys = kTunerFrequencyTag
-(void) startRetrievingStatus:(statusTransactionResult_t)statusResultCallback;
- (void)addOperationWithBlock:(void (^)(void))block;

@end


void RetrieveTunersForScheduling(retrieveTunersorScheduels_t callback);
BOOL CheckForErrorInTransaction(NSDictionary* transationToCheck);

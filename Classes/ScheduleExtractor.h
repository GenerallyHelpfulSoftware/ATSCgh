//
//  ScheduleExtractor.h
//  Signal GH
//
//  Created by Glenn Howes on 1/19/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@protocol TVTuner;

@class ScheduleExtractor;
typedef void(^extraction_result_t)(BOOL success);

@interface ScheduleExtractor : NSObject
@property(nonatomic, strong) NSObject<TVTuner>* tuner;
+(void) startWholeScanWithCallback:(extraction_result_t)callback;

-(void) startToScanAChannelID:(NSManagedObjectID*)aChannelID withCallback:(extraction_result_t)callback; // NSManagedObjectID for TunerChannel
-(void) cancel;

@end

extern NSString* const kScheduleTunerChannelTag;

extern NSString* const kScheduleExtractorError;

extern NSString* const kScheduleParserFinishedParsingChannel;
extern NSString* const kScheduleParserBeginParsingChannel;

extern NSString* const kScheduleParserCompletedScan;
extern NSString* const kScheduleParserBeginScan;

extern NSString* const kScheduleScanFailedNoAvailableTuners;
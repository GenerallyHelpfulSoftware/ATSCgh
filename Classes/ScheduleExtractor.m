//
//  ScheduleExtractor.m
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
//  Created by Glenn Howes on 1/19/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

/*
    For each channel, ask the TVTuner for MasterGuideTables, then use that to ask the TVTuner for the various tables needed to extract schedule information
    (EventInformationTables, ExtendedTextTables, Rating tables, audio information, etc. Uses Notifications to let clients know how this is progressing.
 
 */

#import "ScheduleExtractor.h"
#import "SubchannelManager.h"
#import "TunerStateManager.h"
#import "StringConstants.h"
#import "ATSCTables.h"
#import "MasterGuideTable.h"
#import "SystemTimeTable.h"
#import "TerrestrialVirtualChannelTable.h"
#import "TableExtractor.h"
#import "EventInformationTable.h"
#import "ExtendedTextTable.h"
#import <objc/runtime.h>
#import "SignalGH-Swift.h"

NSString* const kScheduleExtractorError = @"kScheduleExtractorError";
NSString* const kScheduleParserFinishedParsingChannel = @"kScheduleParserFinishedParsingChannel";
NSString* const kScheduleParserBeginParsingChannel = @"kScheduleParserBeginParsingChannel";
NSString* const kScheduleParserCompletedScan = @"kScheduleParserCompletedScan";
NSString* const kScheduleParserBeginScan = @"kSchredulParserBeginScan";

NSString* const kScheduleScanFailedNoAvailableTuners = @"kScheduleScanFailedNoAvailableTuners";

NSString* const kScheduleTunerChannelTag = @"kScheduleTunerChannelTag";

const double kStreamTickPeriod = 0.15;
const CFTimeInterval kTimeToWaitForMasterTable = 30;
const CFTimeInterval kTimeToWaitForEventTables = 60;
const size_t kMaximumPacketBufferLength = kSizeOfATSCPacket*22;


@interface ScheduleExtractor ()
{
    dispatch_queue_t   queue;
    dispatch_block_t    pollingCallback;
}

@property(nonatomic, strong) NSManagedObjectID* activeChannelID;
@property(nonatomic, strong) NSMutableData*     packetBuffer;
@property(nonatomic, assign) size_t             validData;
@property(nonatomic, assign) BOOL finished;
@property(nonatomic, strong) extraction_result_t callback;
@property(nonatomic, strong) SubchannelManager* backgroundManager;
@end


const unsigned char kExtractor[] = "kExtractor";

@implementation ScheduleExtractor


+(void) askTuners:(NSArray*)tuners forStatusResult:(statusTransactionResult_t)statusResultCallback
{
    for(NSObject<TVTuner>* aTuner in tuners)
    {
        [aTuner startRetrievingStatus:statusResultCallback];
    }
}

+(ScheduleExtractor*) getExtractorForTuner:(NSObject<TVTuner>*) aTuner
{
    ScheduleExtractor* result =  objc_getAssociatedObject(aTuner, kExtractor);
    if(result == nil)
    {
        result = [ScheduleExtractor new];
        result.backgroundManager = [[SubchannelManager sharedModel] newChildModel];
        result.tuner = aTuner;
        objc_setAssociatedObject(aTuner, kExtractor, result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
    return result;
}

+(void) scanSubChannels:(NSArray<NSManagedObjectID*> *)favoriteSubchannels withCallback:(extraction_result_t)callback
{
    __block NSMutableArray* channelsToScan = [favoriteSubchannels mutableCopy];
    
    __block SubchannelManager* backgroundManager = [[SubchannelManager sharedModel] newBackgroundChildModel];
    
    RetrieveTunersForScheduling(^(NSArray *scheduableWrappers) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kScheduleParserBeginScan object:self userInfo:nil];
        if(scheduableWrappers.count)
        {
            __block NSInteger wrapperCount = scheduableWrappers.count;
            __block NSMutableArray* extractors = [[NSMutableArray alloc] initWithCapacity:scheduableWrappers.count];
            
            __block UIBackgroundTaskIdentifier backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                
                [channelsToScan removeAllObjects];
            }];
            __block NSInteger outStanding = 0;
            
            [self askTuners:scheduableWrappers forStatusResult:^(NSDictionary *transaction, NSObject<TVTuner> *aTuner) {
                
                NSNumber* frequency = [transaction objectForKey:kTunerFrequencyTag];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    wrapperCount--;
                    
                    if(!CheckForErrorInTransaction(transaction))
                    {
                        NSString*	targetIPAddressString = [transaction objectForKey:kTargetIPAddressTag];
                        if(targetIPAddressString.length == 0)
                        {
                            if(channelsToScan.count)
                            {
                                ScheduleExtractor* anExtractor =  [self getExtractorForTuner:aTuner];
                                anExtractor.backgroundManager = backgroundManager;
                                
                                [extractors addObject:anExtractor];
                                NSManagedObjectID* anID = [channelsToScan lastObject];
                                [channelsToScan removeLastObject];
                                __weak ScheduleExtractor* weakExtractor = anExtractor;
                                anExtractor.callback = ^(BOOL success){
                                    outStanding--;
                                    if(!success)
                                    {
                                        NSLog(@"Missed one: %@", weakExtractor.activeChannelID.description);
                                    }
                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                        ScheduleExtractor* strongExtractor = weakExtractor;
                                        if(channelsToScan.count)
                                        {
                                            outStanding++;
                                            NSManagedObjectID* anID = [channelsToScan lastObject];
                                            [channelsToScan removeLastObject];
                                            [strongExtractor startToScanAChannelID:anID withCallback:strongExtractor.callback];
                                        }
                                        else
                                        {
                                            strongExtractor.callback = nil;
                                            if(frequency.integerValue > 0 )
                                            {
                                                [aTuner startTuningToFrequency:frequency forTransaction:transaction withCallback:^(NSDictionary * setFrequencyTransaction) {
                                                    
                                                }];
                                            }
                                            if(outStanding == 0)
                                            {
                                                [[NSNotificationCenter defaultCenter] postNotificationName:kScheduleParserCompletedScan object:strongExtractor userInfo:nil];
                                                
                                                if(callback)
                                                {
                                                    callback(YES);
                                                }
                                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                    
                                                    [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskID];
                                                    backgroundTaskID = UIBackgroundTaskInvalid;
                                                }];
                                            }
                                        }
                                    }];
                                };
                                outStanding++;
                                [anExtractor startToScanAChannelID:anID  withCallback:anExtractor.callback];                            }
                        }
                    }
                    else if(wrapperCount == 0 && extractors.count == 0)
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kScheduleScanFailedNoAvailableTuners object:self];
                        if(callback)
                        {
                            callback(NO);
                        }
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskID];
                            backgroundTaskID = UIBackgroundTaskInvalid;
                        }];
                    }
                    
                    
                }];
            }];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kScheduleScanFailedNoAvailableTuners object:self];
                if(callback)
                {
                    callback(NO);
                }
                
            }];
        }
        
    });

}

+(void) startWholeScanWithCallback:(extraction_result_t)callback
{
    [[SubchannelManager sharedModel] retrieveFavoriteSubChannelsIDs:^(NSArray<NSManagedObjectID*>*favoriteSubchannels, NSError *error) {
        
        if(error != nil)
        {
            callback(false);
        }
        else
        {
            [self scanSubChannels:favoriteSubchannels withCallback:callback];
        }
    }];
}



-(void) cleanupPolling
{
    if(self.tuner.pollingSource)
    {
        self.tuner.pollingSource = nil;
        self.validData = 0;
        NSDictionary* startTransaction = @{kScheduleTunerChannelTag:self.activeChannelID};
        [self.tuner startStoppingStreamingWithTransaction:startTransaction withCallback:^(NSDictionary * stopTransaction) {
            
        }];
    }
}

-(void) ticking:(NSTimer*)aTimer
{
    if(pollingCallback)
    {
        pollingCallback();
    }
}

-(dispatch_source_t) timer
{
    dispatch_source_t result = self.tuner.pollingSource;
    if(result == nil)
    {
        
        result = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        
        self.tuner.pollingSource = result;
        dispatch_source_set_timer(result, dispatch_walltime(NULL, 0), kStreamTickPeriod * NSEC_PER_SEC, kStreamTickPeriod * NSEC_PER_SEC); // I could probably do with a lot of leeway
        self.packetBuffer = [[NSMutableData alloc] initWithLength:kMaximumPacketBufferLength];
        self.validData = 0;
    }
    return result;
}

-(void) setPollingCallback:(dispatch_block_t)callback
{
    dispatch_source_t timer = self.tuner.pollingSource;
    if(timer == nil)
    {
        timer = self.timer;
    }
    else
    {
        dispatch_suspend(timer);
        self.validData = 0;
    }
    pollingCallback = callback;
    dispatch_source_set_event_handler(timer, callback);
    dispatch_resume(timer);
    
}

-(BOOL) foundMasterTables:(NSDictionary*)extractedTables
{
    BOOL hasMasterGuide = NO;
    BOOL hasSystemTime = NO;
    BOOL hasTerrestrialChannels = NO;
    
    for(ATSCTable* aTable in extractedTables.allValues)
    {
        if([aTable isKindOfClass:[MasterGuideTable class]])
        {
            hasMasterGuide = YES;
        }
        else if([aTable isKindOfClass:[SystemTimeTable class]])
        {
            hasSystemTime = YES;
        }
        else if([aTable isKindOfClass:[TerrestrialVirtualChannelTable class]])
        {
            hasTerrestrialChannels = YES;
        }
    }
    
    BOOL result = hasSystemTime && hasMasterGuide && hasTerrestrialChannels;
    return result;
}

-(NSString*) pidsToFilterStringForMasterGuideTable:(MasterGuideTable*) masterTable
{
    NSMutableString* pidFilterString = [[NSMutableString alloc] initWithCapacity:8*masterTable.tableDefinitions.count];
    
    for(NSDictionary* aTableDefinition in masterTable.tableDefinitions.allValues)
    {
        switch ([aTableDefinition[kTableTypeDefinitionKey] integerValue]) {
            default:
            case kTableTypeUnknownDefinition:
            case kTerrestrialVCTTableDefinition:
            case kCableVCTDefinition:
            case kDirectedChannelChangeSelectionCodeTableDefinition:
            case kLongTermServiceTableDefinition:
            case kShortFormVirtualChannelTableVCMSubtypeDefinition:
            case kShortFormVirtualChannelTableDCMSubtypeDefinition:
            case kShortFormVirtualChannelTableICMSubtypeDefinition:
            case kNetworkInformationTableCDSTableSubtypeDefinition:
            case kNetworkInformationTableMMSTableSubtypeDefinition:
            case kNetworkTextTableSNSSubTypeDefinition:
            case kUserPrivateTableDefinition:
            case kCurrentPATTableDefinition:
            case kNextPATTableDefinition:
            case kNextCATTableDefinition:
            case kCurrentCATTableDefinition:
            case kCurrentPMTTableDefinition:
            case kNextPMTTableDefinition:
            case kATSCMGTTableDefinition:
            case kAggregateEventInformationTableDefinition:
            case kAggregateExtendedTextTableDefinition:
            case kExtendedTextTableForDataEventTableDefinition:
            case kDataEventTableDefinition:
            case kDirectedChannelChangeTableWithDCCDefinition:
            case kAggregateDataEventTableDefinition:
            case kSatelliteVirtualChannelTableDefinition:
                // ignore
                break;
                
            case kRatingRegionTableDefinition: // 14
            case kChannelExtendedTextTableDefinition:
            case kExtendedEventTextTableDefinition: // 13
            case kEventInformationTableDefinition: // 12
            {
                NSNumber* pid = aTableDefinition[kTableTypePIDKey];
                if(pid.integerValue != 0)
                {
                    NSString* aString = [[NSString alloc] initWithFormat:@"0x%04lx", (long)pid.integerValue];
                    if(pidFilterString.length)
                        [pidFilterString appendFormat:@" %@", aString];
                    else
                    {
                        [pidFilterString appendString:aString];
                    }
                }
            }
                break;
        }
    }
    return [pidFilterString copy];
}

-(BOOL) doneLookingForEvents:(NSDictionary*)extractedTables definedByMasterGuideTable:(MasterGuideTable*)masterTable
{
    NSUInteger countOfExtendedText = 0;
    NSUInteger countOfEventInformation = 0;
    
    for(NSDictionary* aDefinition in masterTable.tableDefinitions.allValues)
    {
        if([aDefinition[kTableTypeDefinitionKey] integerValue] == kEventInformationTableDefinition)
        {
            countOfEventInformation++;
        }
        else if([aDefinition[kTableTypeDefinitionKey] integerValue] == kExtendedEventTextTableDefinition)
        {
            countOfExtendedText++;
        }
    }
    
    for(ATSCTable* aTable in extractedTables.allValues)
    {
        if(countOfEventInformation && [aTable isKindOfClass:[EventInformationTable class]])
        {
            countOfEventInformation--;
        }
        else if(countOfExtendedText && [aTable isKindOfClass:[ExtendedTextTable class]])
        {
            countOfExtendedText--;
        }

    }
    
    BOOL result = countOfEventInformation == 0 && countOfExtendedText == 0;
    return result;
}

-(void) saveOutTables:(NSDictionary*)extractedTables definedByMasterGuideTable:(MasterGuideTable*)masterTable andTerrestrialChannels:(TerrestrialVirtualChannelTable*)terrestrialTable forTransaction:(NSDictionary*)transaction
{
    [self.backgroundManager saveOutTables:extractedTables definedByMasterGuideTable:masterTable
                            andTerrestrialChannels:terrestrialTable forTunerChannelWithID:transaction[kScheduleTunerChannelTag]];
}

-(void) pollForEventInformation:(NSDictionary*)transaction usingMasterGuideTable:(MasterGuideTable*)masterTable andStartingTables:(NSDictionary*)startingTables andTerrestrialChannels:(TerrestrialVirtualChannelTable*)terrestrialTable  withCallback:(extraction_result_t)callback
{
    __weak ScheduleExtractor* weakSelf = self;
    __block CFTimeInterval endTime = CFAbsoluteTimeGetCurrent() + kTimeToWaitForEventTables;
    __block NSMutableDictionary* extractedTables = [startingTables mutableCopy];
    __block NSDictionary* extractors = [[NSDictionary alloc] init];
    
    
    [self setPollingCallback:^{
        size_t availableSize = kMaximumPacketBufferLength-weakSelf.validData;
        
        if(!weakSelf.tuner.canReceiveData)
        {
            [weakSelf cleanupPolling];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                callback(NO);
            }];
        }
        else
        {
            size_t sizeRetrieved = 0;
            const uint8_t* data =   [weakSelf.tuner retrieveDataOfMaximumSize:availableSize returningSizeRetrieved:&sizeRetrieved];
            if(data != NULL && sizeRetrieved >= kSizeOfATSCPacket)
            {
                unsigned char* packetBuffer = weakSelf.packetBuffer.mutableBytes;
                
                memcpy(&packetBuffer[weakSelf.validData], data, sizeRetrieved);
                weakSelf.validData = weakSelf.validData + sizeRetrieved;
                [TableExtractor extractTablesFromData:packetBuffer ofValidLength:weakSelf.validData withSetOfExtractors:extractors intoCallback:^(NSUInteger endIndex, NSDictionary* newExtractors, NSDictionary* tables) {
                    extractors = newExtractors;
                    if(tables)
                    {
                        [extractedTables addEntriesFromDictionary:tables];
                    }
                    if(endIndex < weakSelf.validData) // shift the excess back to the beginning of the buffer. maybe I should search for a G?
                    {
                        weakSelf.validData = weakSelf.validData-endIndex;
                        memcpy(packetBuffer, &packetBuffer[endIndex], weakSelf.validData);
                    }
                    else
                    {
                        weakSelf.validData = 0;
                    }
                }];
                if([weakSelf doneLookingForEvents:extractedTables definedByMasterGuideTable:masterTable])
                {
                    [weakSelf cleanupPolling];
                    [weakSelf saveOutTables:extractedTables definedByMasterGuideTable:masterTable andTerrestrialChannels:terrestrialTable
                             forTransaction:transaction];
                    callback(YES);
                }
                else if(endTime < CFAbsoluteTimeGetCurrent())
                {
                    [weakSelf cleanupPolling];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        callback(NO);
                    }];
                }
            }
            else if(endTime < CFAbsoluteTimeGetCurrent())
            {
                [weakSelf cleanupPolling];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    callback(NO);
                }];
            }
        }
    }];

}

-(void) pollForScheduleTablesWithTransaction:(NSDictionary*)transaction andExtractedTables:(NSDictionary*)masterTables withCallback:(extraction_result_t)callback
{
    __block SystemTimeTable* timeTable = nil;
    __block MasterGuideTable* masterTable = nil;
    __block TerrestrialVirtualChannelTable* terrestrialChannels  = nil;
    for(ATSCTable* aTable in masterTables.allValues)
    {
        if([aTable isKindOfClass:[MasterGuideTable class]])
        {
            masterTable = (MasterGuideTable*)aTable;
        }
        else if([aTable isKindOfClass:[SystemTimeTable class]])
        {
            timeTable = (SystemTimeTable*)aTable;
        }
        else if([aTable isKindOfClass:[TerrestrialVirtualChannelTable class]])
        {
            terrestrialChannels =(TerrestrialVirtualChannelTable*)aTable;
        }
    }
    
    NSString* pidFilterString = [self pidsToFilterStringForMasterGuideTable:masterTable];
    
    NSManagedObjectID* objectID = transaction[kScheduleTunerChannelTag];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if(pidFilterString.length)
        {
            [[SubchannelManager sharedModel] retrieveChannelWithID:objectID intoCallback:^(TunerChannel *tunerChannel, NSError *error) {
                
                [self.tuner startSettingPIDFilter:pidFilterString forTransaction:transaction withCallback:^(NSDictionary *setFilterTransaction) {
                    if(!CheckForErrorInTransaction(setFilterTransaction))
                    {
                        [self.tuner startStreamingWithTransaction:setFilterTransaction withCallback:^(NSDictionary *startStreamingTransaction)
                         {
                             if(!CheckForErrorInTransaction(startStreamingTransaction))
                             {
                                 NSDictionary* startingTables = @{masterTable.uniqueKey:masterTable, timeTable.uniqueKey:timeTable, terrestrialChannels.uniqueKey:terrestrialChannels};
                                 [self pollForEventInformation:startStreamingTransaction usingMasterGuideTable:masterTable andStartingTables:startingTables
                                        andTerrestrialChannels:terrestrialChannels withCallback:(callback)];
                             }
                             else
                             {
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kScheduleExtractorError object:self userInfo:setFilterTransaction];
                                 callback(NO);
                             }
                         }];
                    }
                    else
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kScheduleExtractorError object:self userInfo:setFilterTransaction];
                        callback(NO);
                    }
                }];
            }];
        }
        else
        {
            callback(NO);
        }
    }];
}
//pollForMasterTable - periodically grab the data from the data stream and look for an ATSC MGT table (and a system time table)
-(void) pollForMasterTable:(NSDictionary*)transaction withCallback:(extraction_result_t)callback
{
    __weak ScheduleExtractor* weakSelf = self;
    __block CFTimeInterval endTime = CFAbsoluteTimeGetCurrent() + kTimeToWaitForMasterTable;
    __block NSMutableDictionary* extractedTables = [[NSMutableDictionary alloc] initWithCapacity:32];
    __block NSDictionary* extractors = [[NSDictionary alloc] init];
    
    [self setPollingCallback:^{
        size_t availableSize = kMaximumPacketBufferLength-weakSelf.validData;
        if(!weakSelf.tuner.canReceiveData)
        {
            [weakSelf cleanupPolling];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                callback(NO);
            }];
        }
        else
        {
            size_t sizeRetrieved = 0;
            const uint8_t* data =   [weakSelf.tuner retrieveDataOfMaximumSize:availableSize returningSizeRetrieved:&sizeRetrieved];
            if(data != NULL && sizeRetrieved > 0)
            {
                unsigned char* packetBuffer = weakSelf.packetBuffer.mutableBytes;
                
                memcpy(&packetBuffer[weakSelf.validData], data, sizeRetrieved);
                weakSelf.validData = weakSelf.validData + sizeRetrieved;
                
                [TableExtractor extractTablesFromData:packetBuffer ofValidLength:weakSelf.validData withSetOfExtractors:extractors intoCallback:^(NSUInteger endIndex, NSDictionary* newExtractors, NSDictionary* tables) {
                    extractors = newExtractors;
                    if(tables.count)
                    {
                        [extractedTables addEntriesFromDictionary:tables];
                    }
                    if(endIndex < weakSelf.validData) // shift the excess back to the beginning of the buffer
                    {
                        weakSelf.validData = weakSelf.validData-endIndex;
                        memcpy(packetBuffer, &packetBuffer[endIndex], weakSelf.validData);
                    }
                    else
                    {
                        weakSelf.validData = 0;
                    }
                }];
                if([weakSelf foundMasterTables:extractedTables])
                {
                    [weakSelf cleanupPolling];
                    [weakSelf pollForScheduleTablesWithTransaction:transaction andExtractedTables:extractedTables withCallback:callback];
                }
                else if(endTime < CFAbsoluteTimeGetCurrent())
                {
                    [weakSelf cleanupPolling];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        callback(NO);
                    }];
                }
            }
            else if(endTime < CFAbsoluteTimeGetCurrent())
            {
                [weakSelf cleanupPolling];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    callback(NO);
                }];
            }
        }
    }];
}


-(void) scanChannel:(TunerChannel *) tunerChannel withTransaction:(NSDictionary*)transaction withCallback:(extraction_result_t)callback
{
    if(self.activeChannelID == nil)
    {
        TunerSubchannel* subChannel = (TunerSubchannel*) tunerChannel.subchannels.allObjects.firstObject;
        self.activeChannelID = subChannel.objectID;
        
    }
    
    
    NSString* pidFiter = @"0x1ffb"; // magic number that filters out audio, video and anything not related to schedule data
    [self.tuner startSettingPIDFilter:pidFiter forTransaction:transaction withCallback:^(NSDictionary *setFilterTransaction) {
        if(!CheckForErrorInTransaction(setFilterTransaction))
        {
            [self.tuner startStreamingWithTransaction:setFilterTransaction withCallback:^(NSDictionary *startStreamingTransaction)
             {
                 if(!CheckForErrorInTransaction(startStreamingTransaction))
                 {
                     [self.tuner addOperationWithBlock:^{
                         
                         [self pollForMasterTable:startStreamingTransaction withCallback:callback];
                     }];
                 }
                 else
                 {
                     [[NSNotificationCenter defaultCenter] postNotificationName:kScheduleExtractorError object:self userInfo:setFilterTransaction];
                     callback(NO);
                 }
             }];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kScheduleExtractorError object:self userInfo:setFilterTransaction];
            callback(NO);
        }
    }];

}

-(void) startToScanAChannelID:(NSManagedObjectID*)channelID withCallback:(extraction_result_t)callback
{
    self.activeChannelID = channelID;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kScheduleParserBeginParsingChannel object:self userInfo: @{kScheduleTunerChannelTag:self.activeChannelID}];
    [[SubchannelManager sharedModel] retrieveChannelWithID:channelID intoCallback:^(TunerChannel *tunerChannel, NSError *error) {
        if(tunerChannel != nil && error == nil)
        {
            NSDictionary* startTransaction = @{kScheduleTunerChannelTag:self.activeChannelID};
            NSNumber* frequency = tunerChannel.frequency;
            self.tuner.scanningSchedule = YES;
            [self.tuner startTuningToFrequency:frequency forTransaction:startTransaction withCallback:^(NSDictionary * setFrequencyTransaction) {
                if(!CheckForErrorInTransaction(setFrequencyTransaction))
                {
                    [self scanChannel:tunerChannel withTransaction:setFrequencyTransaction withCallback:^(BOOL success) {
                     
                        
                        self.tuner.scanningSchedule = NO;
                        callback(success);
                    }];
                }
                else
                {
                    self.tuner.scanningSchedule = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kScheduleExtractorError object:self userInfo:setFrequencyTransaction];
                    callback(NO);
                }
            } ];
        }
        else
        {
            callback(NO);
        }
    }];
}
 

-(void) cancel
{
}

@end

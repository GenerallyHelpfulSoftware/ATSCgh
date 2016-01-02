//
//  TunerSubchannel+TV.m
//  Signal GH
//
//  Created by Glenn Howes on 12/28/13.
//  Copyright (c) 2013-2015 Generally Helpful Software. All rights reserved.
//

#import "TunerSubchannel+TV.h"
#import "BroadcasterModel.h"
#import "TunerChannel+TV.h"
#import "Subchannel.h"
#import "Network+Map.h"
#import "TerrestrialVirtualChannelTable.h"
#import "EventInformationTable.h"
#import "ExtendedTextTable.h"
#import "ScheduledShow+TV.h"
#import "SystemTimeTable.h"
#import "TunerChannel+TV.h"
#import "Tower.h"

@implementation TunerSubchannel (TV)

-(Tower*)tower
{
    Tower* result = self.channel.tower;
    return result;
}

-(NSString*) completedDescription
{
    __block NSMutableString* mutableResult = [[NSMutableString alloc] initWithCapacity:512];
    [self.managedObjectContext performBlockAndWait:^{
        Network* myNetwork = self.network;
        NSString* networkName = myNetwork.name;
        if(networkName.length)
        {
            [mutableResult appendString:networkName];
        }
        Tower* myTower = self.tower;
        NSString* towersCallsign = myTower.callSign;
        if(towersCallsign.length)
        {
            if(mutableResult.length)
            {
                [mutableResult appendString:@" • "];
            }
            [mutableResult appendString:towersCallsign];
        }
        NSString* mySubChannel = [self completedSubchannelNumber];
        
        if(mutableResult.length == 0 && self.userVisibleName.length)
        {
            [mutableResult appendString:self.userVisibleName];
        }
        if(mutableResult.length)
        {
            [mutableResult appendString:@" • "];
        }
        [mutableResult appendString:mySubChannel];
        
        TunerChannel* myChannel = self.channel;
        NSNumber* majorChannel = myChannel.number;
        NSString* majorChannelString = majorChannel.stringValue;
        if(majorChannelString.length)
        {
            [mutableResult appendFormat:@"(%@)",majorChannelString];
        }
            
    }];
    return [mutableResult copy];
}

-(NSString*)completedSubchannelNumber
{
    __block NSString* result = nil;
    [self.managedObjectContext performBlockAndWait:^{
      
        result = [NSString stringWithFormat:@"%@.%@", self.virtualMajorChannelNumber.stringValue, self.virtualMinorChannelNumber.stringValue];
        
    }];
    return result;
}


-(void)setUserVisibleName:(NSString *)fullName {
    
    [self willChangeValueForKey:@"userVisibleName"];
    
    
    [self didChangeValueForKey:@"userVisibleName"];
}

-(NSString*) userVisibleName
{
    [self willAccessValueForKey:@"userVisibleName"];
    
    __block NSString* result = nil;
    [self.managedObjectContext performBlockAndWait:^{
        
        result = [self completedSubchannelNumber];
        NSString* networkName = self.network.name;
        if(networkName.length == 0)
        {
            if(self.programName.length)
            {
                result = [result stringByAppendingFormat:@" %@",self.programName];
            }
            else if(self.channel.callsign.length)
            {
                result = [result stringByAppendingFormat:@" %@",self.channel.callsign];
            }
        }
        else
        {
            result = [result stringByAppendingFormat:@" %@",networkName];
        }
    }];
    [self didAccessValueForKey:@"userVisibleName"];
    return result;
}

-(Subchannel*)subchannel
{
    __block Subchannel* result = nil;
    [self.managedObjectContext performBlockAndWait:^{
        Tower* myTower = self.tower;
        if(myTower != nil)
        {
            NSSet* subChannels = myTower.subchannels;
            NSString* subChannelString = [self completedSubchannelNumber];
            for(Subchannel* aSubchannel in subChannels)
            {
                if([aSubchannel.virtualNumber isEqualToString:subChannelString])
                {
                    result = aSubchannel;
                    break;
                }
            }
        }
    }];
    return result;
}

-(Network*)network
{
    __block Network* result = nil;
    
    [self.managedObjectContext performBlockAndWait:^{
        
        result = self.subchannel.network;
        
    }];
    return result;
}

-(NSString*)userViewableDescription
{
    __block NSString* result = nil;
    [self.managedObjectContext performBlockAndWait:^{
        result = self.programName;
        Network* myNetwork = self.network;
        NSString* callSign = self.channel.callsign;
        if(callSign == nil) callSign = @"";
        if(myNetwork != nil)
        {
            result = [NSString stringWithFormat:@"%@ ❖ %@", callSign, myNetwork.name];
        }
    }];
    return result;
}

-(void) extractTables:(NSDictionary*)extractedTables withVirtualChannel:(TerrestrialVirtualChannel*) aVirtualChannel
{
    [self.managedObjectContext performBlockAndWait:^{
        NSEntityDescription *showEntity = [NSEntityDescription entityForName:@"ScheduledShow" inManagedObjectContext:[self managedObjectContext]];
        SystemTimeTable* aTimeTable = nil;
        for(ATSCTable* aTable in extractedTables.allValues)
        {
            if([aTable isKindOfClass:[SystemTimeTable class]])
            {
                aTimeTable = (SystemTimeTable*)aTable;
                break;
            }
        }
        
        NSTimeInterval timeOffset = 0;
        if(aTimeTable != nil)
        {
            timeOffset  = -aTimeTable.clockDifferenceInSeconds;
        }
        else
        {
            NSTimeZone* myTimeZone = [NSTimeZone defaultTimeZone];
            timeOffset = [myTimeZone secondsFromGMT];
        }
        NSDate* now = [NSDate date];
        
        NSMutableArray* eventInformationRecords = [[NSMutableArray alloc] initWithCapacity:extractedTables.count*10];
        
        for(ATSCTable* aTable in extractedTables.allValues)
        {
            if([aTable isKindOfClass:[EventInformationTable class]])
            {
                EventInformationTable* anEventTable = (EventInformationTable*)aTable;
                if(anEventTable.source_id == aVirtualChannel.source_id)
                {
                    [eventInformationRecords addObjectsFromArray:anEventTable.records];
                }
            }
        }
        [eventInformationRecords sortUsingComparator:^NSComparisonResult(EventInformationRecord* obj1, EventInformationRecord* obj2) {
            NSComparisonResult result = NSOrderedSame;
            
            if(obj1.start_time > obj2.start_time)
            {
                result = NSOrderedDescending;
            }
            else  if(obj1.start_time < obj2.start_time)
            {
                result = NSOrderedAscending;
            }
            return result;
        }];
        
        NSMutableArray* sortedShows = [self.shows.allObjects mutableCopy];
        [sortedShows sortUsingComparator:^NSComparisonResult(ScheduledShow* obj1, ScheduledShow* obj2) {
            NSComparisonResult result = [obj1.start_time compare:obj2.start_time];
            return result;
        }];
        
        NSUInteger countOfEvents = eventInformationRecords.count;
        
        NSTimeInterval timeOffsetSince1970 = timeOffset+[SystemTimeTable beginningOf1980];
        NSTimeInterval nowTimeInterval = now.timeIntervalSince1970;
        
        NSMutableArray* showsToRemove = [NSMutableArray new];
        NSMutableArray* eventsToAdd = [NSMutableArray new];
        NSInteger eventTableIndex = 0;
        NSTimeInterval lastRecordStartTime = timeOffsetSince1970;
        NSTimeInterval lastRecordEndTime = timeOffsetSince1970;
        for(ScheduledShow* aShow in sortedShows)
        {
            NSTimeInterval showStartTime = aShow.start_time.timeIntervalSince1970;
            NSTimeInterval showEndTime = aShow.end_time.timeIntervalSince1970;
            if(nowTimeInterval > showEndTime)
            {
                [showsToRemove addObject:aShow];
            }
            else
            {
                while(eventTableIndex < countOfEvents)
                {
                    EventInformationRecord* aRecord = eventInformationRecords[eventTableIndex];
                    NSTimeInterval aRecordStartTime = aRecord.start_time + timeOffsetSince1970;
                    NSTimeInterval aRecordEndTime = aRecord.length_in_seconds+aRecordStartTime;
                    if(fabs(lastRecordStartTime-aRecordStartTime) < 30 && fabs(lastRecordEndTime-aRecordEndTime) < 30)
                    { // skipping over redundant one
                        eventTableIndex++;
                    }
                    else
                    {
                        lastRecordStartTime = aRecordStartTime;
                        lastRecordEndTime = aRecordEndTime;
                        if(aRecordEndTime <= nowTimeInterval)
                        {
                            eventTableIndex++;
                        }
                        else if(aRecordEndTime < showStartTime)
                        {
                            [eventsToAdd addObject:aRecord];
                            eventTableIndex++;
                        }
                        else if(aRecordStartTime > showEndTime)
                        {
                            break;
                        }
                        else
                        {
                            eventTableIndex++;
                            
                            NSDate* oldStartTimeNearestMinute = [aShow start_time];
                            [aShow updateFromEventRecord:aRecord withTimeOffest:timeOffset];
                            NSDate* newStartTimeNarestMinute = [aShow start_time];
                            if(![oldStartTimeNearestMinute isEqualToDate:newStartTimeNarestMinute])
                            {
                                [showsToRemove addObject:aShow];
                                
                                [eventsToAdd addObject:aRecord];
                            }
                            break;
                        }
                    }
                }
                if(eventTableIndex >= countOfEvents)
                {
                    break;
                }
            }
        }
        for(ScheduledShow* aShow in showsToRemove)
        {
            [self.managedObjectContext deleteObject:aShow];
        }
        
        if(eventTableIndex < countOfEvents)
        {
            for(NSUInteger index = eventTableIndex; index < countOfEvents; index++)
            {
                EventInformationRecord* aRecord = eventInformationRecords[index];
                NSTimeInterval aRecordStartTime = aRecord.start_time + timeOffsetSince1970;
                NSTimeInterval aRecordEndTime = aRecord.length_in_seconds+aRecordStartTime;
                if(fabs(lastRecordStartTime-aRecordStartTime) < 30 && fabs(lastRecordEndTime-aRecordEndTime) < 30)
                {
                }
                else
                {
                    lastRecordStartTime = aRecordStartTime;
                    lastRecordEndTime = aRecordEndTime;
                    if(aRecordEndTime > nowTimeInterval)
                    {
                        [eventsToAdd addObject:aRecord];
                    }
                }
            }
        }
        
        for(EventInformationRecord* aRecord in eventsToAdd)
        {
            NSDate* endDate = [ScheduledShow endDateFromEventRecord:aRecord withTimeOffest:timeOffset];
            if([endDate timeIntervalSinceDate:now] > 0)
            {
                ScheduledShow* theShow = [[ScheduledShow alloc] initWithEntity:showEntity insertIntoManagedObjectContext:[self managedObjectContext]];
                [theShow updateFromEventRecord:aRecord withTimeOffest:timeOffset];
                
                theShow.subChannel = self;
                [self addShowsObject:theShow];
            }
        }

        for(ATSCTable* aTable in extractedTables.allValues)
        {
            if([aTable isKindOfClass:[ExtendedTextTable class]])
            {
                ExtendedTextTable* textTable = (ExtendedTextTable*)aTable;
                if(textTable.source_id == aVirtualChannel.source_id)
                {
                    for(ScheduledShow* aShow in self.shows)
                    {
                        NSInteger event_id = aShow.event_id.integerValue;
                        
                        if(textTable.event_id == event_id)
                        {
                            [aShow updateFromExtendedTextTable:textTable];
                            break;
                        }
                    }
                }
            }
        }
    }];
}

@end

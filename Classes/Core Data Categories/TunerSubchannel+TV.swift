//
//  TunerSubchannel+TV.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/9/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreData

public extension TunerSubchannel
{
    public var tower : Tower?
    {
        return self.channel?.tower
    }
    
    @objc var completedSubchannelString : String?
    {
        var result : String? = nil
        
        self.managedObjectContext?.performAndWait {
            switch(self.virtualMajorChannelNumber, self.virtualMinorChannelNumber)
            {
                case (.some(let major), .some(let minor)):
                    result = "\(major).\(minor)"
                case (.some(let major), _):
                    result = "\(major)"
                default:
                break
                
            }
        }
        
        return result
    }
    
    @objc public var completedDescription : String?
    {        
        var result = ""
        self.managedObjectContext?.performAndWait {
            if let networkName = self.network?.name
            {
                result = networkName
            }
            if let callSign = self.tower?.callSign
            {
                result = result.isEmpty ? callSign : "\(result) • \(callSign)"
            }
            if let subChannelString = self.completedSubchannelString
            {
                result = result.isEmpty ? subChannelString : "\(result) • \(subChannelString)"
            }
            
            if result.isEmpty
            {
                if let uservisibleName = self.userVisibleName
                {
                    result =    uservisibleName
                }
            }
            
            if let majorChannel = self.channel?.number , !result.isEmpty
            {
                result = "\(result)(\(majorChannel))"
            }
            
        }
        
        if result.isEmpty
        {
            return nil
        }
        
        return result
    }
    
//    public var userVisibleName : String?
//    {
//        var result = self.completedSubchannelString ?? ""
//        self.managedObjectContext?.performAndWait {
//            let networkName = self.network?.name
//            let programName = self.programName
//            let callSign = self.channel?.callsign
//            switch (networkName, programName, callSign)
//            {
//                case (.some(let name), _, _):
//                    result = result.isEmpty ? name : "\(result) \(name)"
//                case (_, .some(let program), _):
//                    result = result.isEmpty ? program : "\(result) \(program)"
//                case (_, _, .some(let callSign)):
//                    result = result.isEmpty ? callSign : "\(result) \(callSign)"
//            }
//            
//        }
//        
//        return result
//    }
    public var subchannel : Subchannel?
    {
        var result : Subchannel? = nil
        self.managedObjectContext?.performAndWait {
            guard let  subchannels = self.tower?.subchannels as? Set<Subchannel>, let subchannelString = self.virtualMinorChannelNumber?.stringValue else
            {
                return
            }
            
            
            result = subchannels.first(where: { (aSubchannel) -> Bool in
                aSubchannel.virtualNumber == subchannelString
            })
        }
        return result
    }
    
    @objc public var network : Network?
    {
        var result : Network? = nil
        self.managedObjectContext?.performAndWait {
            result = self.subchannel?.network
        }
        return result
    }
    
    public var userViewableDescription : String?
    {
        var result : String? = nil
        self.managedObjectContext?.performAndWait {
            result = self.programName
            if let networkName = self.network?.name, let callSign = self.channel?.callsign
            {
                result = "\(callSign) ❖ \(networkName)"
            }
        }
        return result
    }
    
    @objc public func extract(tables : Dictionary<String, AnyObject>,  withVirtualChannel virtualChanel : TerrestrialVirtualChannel)
    {
        guard let context = self.managedObjectContext else
        {
            return
        }
        context.performAndWait {
            
            let showEntity = NSEntityDescription.entity(forEntityName: "ScheduledShow", in: context)
            var timeOffset : TimeInterval = 0.0
            
            if let aTimeTable = tables.values.first(where: { (anObject) -> Bool in
                return anObject is SystemTimeTable
            })
            {
                timeOffset = -aTimeTable.clockDifferenceInSeconds
            }
            else
            {
                let myTimeZone = NSTimeZone.default
                timeOffset = TimeInterval(myTimeZone.secondsFromGMT())
            }
            
            let now = NSDate()
            
            
            let tableValues = tables.flatMap{(aPair) -> EventInformationTable? in
                return aPair.value as? EventInformationTable
            }
            
            let eventInformationRecords = tableValues.flatMap{ (anEventTable) -> [EventInformationRecord]? in
                
                if anEventTable.source_id == virtualChanel.source_id
                {
                    return anEventTable.records
                }
                else
                {
                    return nil
                }
                }.flatMap{return $0}
            
        
            
            let sortedEventInformationRecords = eventInformationRecords.sorted
            {
                record0, record1 in
                return record0.start_time < record1.start_time
            }
            
            let showSet = (self.shows ?? NSSet()) as! Set<ScheduledShow>
            let shows = [ScheduledShow](showSet).flatMap{ (aShow) -> (ScheduledShow?) in
                guard let _ = aShow.start_time, let _ = aShow.end_time else
                {
                    return nil
                }
                return aShow
            }
            let sortedShows = shows.sorted{ show0, show1 in
                guard let startTime0 = show0.start_time, let startTime1 = show1.start_time else
                {
                    return show0.start_time != show1.start_time && show0.start_time != nil
                }
                return startTime0.timeIntervalSinceReferenceDate < startTime1.timeIntervalSinceReferenceDate
            }
            
            let countOfEvents = eventInformationRecords.count
            let timeOffsetSince1970 = timeOffset + SystemTimeTable.beginningOf1980()
            let nowTimeInterval = now.timeIntervalSince1970
            
            var showsToRemove = [ScheduledShow]()
            var eventsToAdd = [EventInformationRecord]()
            var eventTableIndex = 0
            var lastRecordStartTime = timeOffsetSince1970
            var lastRecordEndTime = timeOffsetSince1970
            
            for aShow in sortedShows
            {
                let showStartTime = aShow.start_time!.timeIntervalSince1970
                let showEndTime = aShow.end_time!.timeIntervalSince1970
                if nowTimeInterval > showEndTime
                {
                    showsToRemove.append(aShow)
                }
                else
                {
                    while eventTableIndex < countOfEvents
                    {
                        let aRecord = sortedEventInformationRecords[eventTableIndex]
                        let aRecordStartTime = aRecord.start_time + timeOffsetSince1970
                        let aRecordEndTime = aRecord.length_in_seconds+aRecordStartTime
                        if fabs(lastRecordStartTime-aRecordStartTime) < 30 && fabs(lastRecordEndTime-aRecordEndTime) < 30
                        { // skilpping over redundant one
                            eventTableIndex += 1
                        }
                        else
                        {
                            lastRecordStartTime = aRecordStartTime
                            lastRecordEndTime = aRecordEndTime
                            if aRecordEndTime <= nowTimeInterval
                            {
                                eventTableIndex += 1
                            }
                            else if aRecordEndTime < showStartTime
                            {
                                eventsToAdd.append(aRecord)
                                eventTableIndex += 1
                            }
                            else if aRecordStartTime > showEndTime
                            {
                                break
                            }
                            else
                            {
                                eventTableIndex += 1
                                let oldStartTimeNearestMinute = aShow.start_time
                                aShow.update(fromEventRecord: aRecord, withTimeOffset: timeOffset)
                                let newStartTimeNearestMinute = aShow.start_time
                                if oldStartTimeNearestMinute != newStartTimeNearestMinute
                                {
                                    showsToRemove.append(aShow)
                                    eventsToAdd.append(aRecord)
                                    
                                }
                                break
                            }
                        }
                    }
                    
                }
            }
            for aShow in showsToRemove
            {
                context.delete(aShow)
            }
            if eventTableIndex < countOfEvents
            {
                for index in eventTableIndex..<countOfEvents
                {
                    let aRecord = sortedEventInformationRecords[index]
                    let aRecordStartTime = aRecord.start_time + timeOffsetSince1970
                    let aRecordEndTime = aRecord.length_in_seconds + aRecordStartTime
                    if fabs(lastRecordStartTime-aRecordStartTime) < 30 &&
                        fabs(lastRecordEndTime-aRecordEndTime) < 30
                    {
                    }
                    else
                    {
                        lastRecordStartTime = aRecordStartTime
                        lastRecordEndTime = aRecordEndTime
                        if aRecordEndTime > nowTimeInterval
                        {
                            eventsToAdd.append(aRecord)
                        }
                    }
                }
            }
            for aRecord in eventsToAdd
            {
                let endDate = ScheduledShow.endDate(fromEventRecord: aRecord, withTimeOffset: timeOffset)
                if endDate.timeIntervalSince(now as Date) > 0
                {
                    let theShow = ScheduledShow(entity: showEntity!, insertInto: context)
                    theShow.update(fromEventRecord: aRecord, withTimeOffset: timeOffset)
                    theShow.subChannel = self
                    self.addToShows(theShow)
                }
            }
            if let shows = self.shows as? Set<ScheduledShow>
            {
                for aTable in tables.values
                {
                    if let textTable = aTable as? ExtendedTextTable
                    {
                        if textTable.source_id == virtualChanel.source_id
                        {
                            for aShow in shows
                            {
                                if let event_id = aShow.event_id
                                {
                                    if textTable.event_id == event_id.uint16Value
                                    {
                                        aShow.update(fromExtendedTextTable: textTable)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

/*
 
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
 */


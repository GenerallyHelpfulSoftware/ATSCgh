//
//  EventInformationTable.h
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ATSCTables.h"

typedef enum ETMLocation
{
    kNoETMLocation,
    kETMLocatedInPTCCarryingThisPSIP,
    kETMLocatedInPTCSpecifiedByChannelTSID,
    kUknownETMLOcation
}ETMLocation;

@interface EventInformationRecord : NSObject
@property(nonatomic, readonly) UInt16 event_id;
@property(nonatomic, readonly) NSTimeInterval start_time; // seconds since January 6, 1980 (GPS Epoch)
@property(nonatomic, readonly) ETMLocation extendedTextLocation;
@property(nonatomic, readonly) NSTimeInterval length_in_seconds;
@property(nonatomic, readonly) NSArray* titles;
@property(nonatomic, readonly) NSArray* descriptors;

@end

@interface EventInformationTable : ATSCTable
@property(nonatomic, readonly) UInt16 source_id;
@property(nonatomic, readonly) NSArray* records; // EventInformationRecord
@end


//
//  TerrestrialVirtualChannelTable.h
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ATSCTables.h"

typedef enum ATSCServiceType
{
    kATSCServiceTypeReserved,
    kATSCServiceTypeAnalogTV,
    kATSCServiceTypeDigitalTV,
    kATSCServiceTypeAudio,
    kATSCServiceTypeData,
    kATSCServiceTypeSoftware,
    // other values reserved
}ATSCServiceType;

@interface TerrestrialVirtualChannel : NSObject
@property(nonatomic, readonly) UInt16 major_channel_number;
@property(nonatomic, readonly) UInt16 minor_channel_number;
@property(nonatomic, readonly) BOOL         hidden;
@property(nonatomic, readonly) BOOL         hideGuide;
@property(nonatomic, readonly) BOOL         out_of_band;
@property(nonatomic, readonly) ATSCServiceType service_type;
@property(nonatomic, readonly) UInt16 source_id;
@property(nonatomic, readonly) UInt16 channel_TSID;
@property(nonatomic, readonly) UInt16 program_number;
@property(nonatomic, readonly) NSString* short_name;

@end

@interface TerrestrialVirtualChannelTable : ATSCTable
@property(nonatomic, readonly) NSArray* channels;
@property(nonatomic, readonly) UInt16 transport_stream_id; // pid
@end

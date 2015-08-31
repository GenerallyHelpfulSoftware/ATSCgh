//
//  MasterGuideTable.h
//  Signal GH
//
//  Created by Glenn Howes on 1/3/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATSCTables.h"


@class MasterGuideTable;
extern NSString* const kTableTypeKey;
extern NSString* const kTableTypePIDKey;
extern NSString* const kTableVersionNumberKey; // table data gets updated, so you can use the version number to know if somethings changed
extern NSString* const kTableNumberOfBytesKey;
extern NSString* const kTableDescriptorsKey;
extern NSString* const kTableTypeDefinitionKey; // see enumeration below



typedef enum TableDefinitionType
{
    kTableTypeUnknownDefinition = 0,
    kTerrestrialVCTTableDefinition = 1,
    kCableVCTDefinition,
    kChannelExtendedTextTableDefinition,
    kDirectedChannelChangeSelectionCodeTableDefinition,
    kLongTermServiceTableDefinition,
    kShortFormVirtualChannelTableVCMSubtypeDefinition,
    kShortFormVirtualChannelTableDCMSubtypeDefinition,
    kShortFormVirtualChannelTableICMSubtypeDefinition,
    kNetworkInformationTableCDSTableSubtypeDefinition,
    kNetworkInformationTableMMSTableSubtypeDefinition,
    kNetworkTextTableSNSSubTypeDefinition,
    kEventInformationTableDefinition, // 12
    kExtendedEventTextTableDefinition, // 13
    kRatingRegionTableDefinition, // 14
    kUserPrivateTableDefinition,
    kCurrentPATTableDefinition,
    kNextPATTableDefinition,
    kNextCATTableDefinition,
    kCurrentCATTableDefinition,
    kCurrentPMTTableDefinition,
    kNextPMTTableDefinition,
    kATSCMGTTableDefinition,
    kAggregateEventInformationTableDefinition,
    kAggregateExtendedTextTableDefinition,
    kExtendedTextTableForDataEventTableDefinition,
    kDataEventTableDefinition,
    kDirectedChannelChangeTableWithDCCDefinition,
    kAggregateDataEventTableDefinition,
    kSatelliteVirtualChannelTableDefinition
}TableDefinitionType;

@interface MasterGuideTable : ATSCTable
@property(nonatomic, readonly) NSDictionary* tableDefinitions;

@end





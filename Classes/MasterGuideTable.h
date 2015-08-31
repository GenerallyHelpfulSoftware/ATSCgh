//
//  MasterGuideTable.h
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





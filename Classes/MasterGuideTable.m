//
//  MasterGuideTable.m
//  Signal GH
//
//  Created by Glenn Howes on 1/3/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//
//  http://www.interactivetvweb.org/tutorials/dtv_intro/atsc_psip/eit
//
#import "MasterGuideTable.h"
#import "NSString+DigitalTV.h"
#import "TerrestrialVirtualChannelTable.h"
#import "LanguageString.h"



NSString* const kTableTypeKey = @"table_type";
NSString* const kTableTypeDefinitionKey = @"table_type_enum";
NSString* const kTableTypePIDKey = @"table_type_PID";
NSString* const kTableVersionNumberKey = @"table_version_number";
NSString* const kTableNumberOfBytesKey = @"number_bytes";
NSString* const kTableDescriptorsKey = @"descriptors";



@implementation MasterGuideTable

+(TableDefinitionType)definitionTypeFromTableType:(UInt16)table_type
{
    TableDefinitionType result = kTableTypeUnknownDefinition;
    
    switch(table_type)
    {
        case 0:
        case 1:
            result = kTerrestrialVCTTableDefinition;
        break;
        case 2:
        case 3:
            result = kCableVCTDefinition;
        break;
        case 4:
            result = kChannelExtendedTextTableDefinition;
        break;
        case 5:
            result = kDirectedChannelChangeSelectionCodeTableDefinition;
        break;
        case 6:
            result = kLongTermServiceTableDefinition;
        break;
        case 16:
            result = kShortFormVirtualChannelTableVCMSubtypeDefinition;
            break;
        case 17:
            result = kShortFormVirtualChannelTableDCMSubtypeDefinition;
        break;
        case 18:
            result = kShortFormVirtualChannelTableICMSubtypeDefinition;
        break;
        case 32:
            result = kNetworkInformationTableCDSTableSubtypeDefinition;
        break;
        case 33:
            result = kNetworkInformationTableMMSTableSubtypeDefinition;
        break;
        case 48:
        break;
        case 1028:
            result = kCurrentPATTableDefinition;
        break;
        case 1030:
            result = kNextPATTableDefinition;
            break;
        case 1034:
            result = kNextCATTableDefinition;
        break;
        case 1038:
            result = kCurrentCATTableDefinition;
        break;
        case 1040:
            result = kCurrentPMTTableDefinition;
        break;
        case 1044:
            result = kNextPMTTableDefinition;
            break;
        case 1199:
            result = kATSCMGTTableDefinition;
        break;
        default: // now with the ranges
        {
            if(table_type >= 256 && table_type <= 383)
            {
                result = kEventInformationTableDefinition; // subtract 256 to get the k value
            }
            else if(table_type >=512 && table_type <= 639)
            {
                result = kExtendedEventTextTableDefinition;
            }
            else if(table_type >= 769 && table_type <= 1023)
            {
                result = kRatingRegionTableDefinition;
            }
            else if(table_type >= 1024 && table_type <= 4095) // note that some of this range are defined above
            {
                result = kUserPrivateTableDefinition;
            }
            else if(table_type >= 4096 && table_type <= 4164)
            {
                result = kAggregateEventInformationTableDefinition;
            }
            else if(table_type >= 4352 && table_type <= 4607)
            {
                result = kAggregateExtendedTextTableDefinition;
            }
            else if(table_type >= 4608 && table_type <= 4735)
            {
                result = kExtendedTextTableForDataEventTableDefinition;
            }
            else if(table_type >= 4864 && table_type <= 4991)
            {
                result = kDataEventTableDefinition;
            }
            else if(table_type >= 5120 && table_type <= 5375)
            {
                result = kDirectedChannelChangeTableWithDCCDefinition;
            }
            else if(table_type >= 5376 && table_type <= 5503)
            {
                result = kAggregateDataEventTableDefinition;
            }
            else if(table_type >= 5632 && table_type <= 5887)
            {
                result = kSatelliteVirtualChannelTableDefinition;
            }
        }
        break;
    }
    
    return result;
}

-(id)initWithTableHeader:(TableHeader)aHeader packetHeader:(PacketHeader)packetHeader rawData:(const unsigned char*) streamData
{
    if(nil != (self = [super initWithTableHeader:aHeader packetHeader:packetHeader rawData:streamData]))
    {
        
        unsigned char byte7 = streamData[9];
        unsigned char byte8 = streamData[10];
        size_t        byteOffset = 11;
        UInt16        tables_defined = byte7 << 8 | byte8;
        NSMutableDictionary* mutableDefinitions = [[NSMutableDictionary alloc] initWithCapacity:tables_defined];
        
        for(UInt16 tableIndex = 0; tableIndex < tables_defined; tableIndex++)
        {//http://www.interactivetvweb.org/tutorials/dtv_intro/mgt
            NSMutableDictionary* aTableDefinition = [[NSMutableDictionary alloc] initWithCapacity:8];
            unsigned char byte0 = streamData[byteOffset++];
            unsigned char byte1 = streamData[byteOffset++];
            
            UInt16         table_type = byte0 << 8 | byte1;
            NSNumber*        tableTypeNumber = [NSNumber numberWithInt:table_type];
            [aTableDefinition setObject:tableTypeNumber forKey:kTableTypeKey];
            
            TableDefinitionType aDefinitionType = [MasterGuideTable definitionTypeFromTableType:table_type];
            NSNumber* aDefinitionTypeNumber = [NSNumber numberWithInt:aDefinitionType];
            [aTableDefinition setObject:aDefinitionTypeNumber forKey:kTableTypeDefinitionKey];
            
            
            unsigned char byte2 = streamData[byteOffset++];
            unsigned char byte3 = streamData[byteOffset++];
            UInt16         table_type_PID = (byte2 & 31) << 8 | byte3;
            
            [aTableDefinition setObject:[NSNumber numberWithInt:table_type_PID] forKey:kTableTypePIDKey];
            
            unsigned char byte4 = streamData[byteOffset++];
            unsigned int  table_version_number = byte4 & 31;
            
            [aTableDefinition setObject:[NSNumber numberWithInt:table_version_number] forKey:kTableVersionNumberKey];
            
            
            unsigned char byte5 = streamData[byteOffset++];
            unsigned char byte6 = streamData[byteOffset++];
            unsigned char byte7 = streamData[byteOffset++];
            unsigned char byte8 = streamData[byteOffset++];
            
            UInt32      number_bytes = byte5 << 24 | byte6 << 16 | byte7 < 8 | byte8;
            
            [aTableDefinition setObject:[NSNumber numberWithInt:number_bytes] forKey:kTableNumberOfBytesKey];
            
            
            unsigned char byte9 = streamData[byteOffset++];
            unsigned char byte10 = streamData[byteOffset++];
            
            UInt16 table_type_descriptors_length = (byte9 & 15) | byte10;
            byteOffset += table_type_descriptors_length;
            
            
            
            [mutableDefinitions setObject:[aTableDefinition copy] forKey:tableTypeNumber];
        }
        _tableDefinitions = [mutableDefinitions copy];
    }
    return self;
}
@end







//
//  ATSCTables.m
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ATSCTables.h"
#import "MasterGuideTable.h"
#import "TerrestrialVirtualChannelTable.h"
#import "LanguageString.h"
#import "CableVirtualChannelTable.h"
#import "SystemTimeTable.h"
#import "EventInformationTable.h"
#import "RatingRegionTable.h"
#import "ExtendedTextTable.h"


@interface ATSCTable()
@property(nonatomic, readonly) NSString* uniqueKey;
@end

@implementation ATSCTable


-(UInt16) sectionNumber
{
    return self.tableHeader.section_number;
}
-(UInt16) lastSectionNumber
{
    return  self.tableHeader.last_section_number;
}

-(NSString*) uniqueKey
{
    NSString* result = [NSString stringWithFormat:@"%@:%d:%hd", NSStringFromClass(self.class), self.packetHeader.packetID, self.sectionNumber];
    return result;
}

-(id)initWithTableHeader:(TableHeader)aHeader packetHeader:(PacketHeader)packetHeader rawData:(const unsigned char*) streamData
{
    if(nil != (self = [super init]))
    {
        _tableHeader = aHeader;
        _packetHeader = packetHeader;
    }
    return self;
}

@end

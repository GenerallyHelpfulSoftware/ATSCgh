//
//  ATSCTables.h
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableExtractor.h"
typedef struct
{
    unsigned char table_id;
    BOOL          section_syntax_indicator;
    BOOL          private_indicator;
    UInt16          section_length;
    UInt16        table_id_extension;
    unsigned char    version_number;
    BOOL            current_next_indicator;
    unsigned char   section_number;
    unsigned char   last_section_number;
    unsigned char   protocol_version;
    
} TableHeader;


typedef enum ScramblingState
{
    kScramblingStateNone = 0,
    kScramblingStateReserved,
    kScramblingStateEvenKey,
    kScramblingStateOddKey
}ScramblingState;


typedef struct
{
    BOOL transportErrorIndicator;
    BOOL payloadUnitStart;
    BOOL transportPriority;
    unsigned short packetID;
    ScramblingState scramblingControl;
    BOOL adaptationFieldExists;
    BOOL containsPayload;
    unsigned short continuityCounter:4; // 4 bits worth
    
    
}PacketHeader;





@interface ATSCTable : NSObject
@property(nonatomic, readonly) TableHeader tableHeader;
@property(nonatomic, readonly) PacketHeader packetHeader;
@property(nonatomic, readonly) UInt16 sectionNumber;
@property(nonatomic, readonly) UInt16 lastSectionNumber;
-(id)initWithTableHeader:(TableHeader)tableHeader packetHeader:(PacketHeader)packetHeader rawData:(const unsigned char*) streamData;
-(NSString*) uniqueKey;
@end




BOOL CheckTable(const unsigned char* tableStart, size_t remaining, NSUInteger section_length);

extern const size_t kPacketHeaderSerializedSizeBytes;
extern const size_t kMinimumTableSizeBytes;

#define kSizeOfATSCPacket 188
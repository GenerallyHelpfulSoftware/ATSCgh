//
//  ATSCTables.h
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
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableExtractor.h"

NS_ASSUME_NONNULL_BEGIN

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
-(instancetype)initWithTableHeader:(TableHeader)tableHeader packetHeader:(PacketHeader)packetHeader rawData:(const unsigned char*) streamData;
-(nullable instancetype) init __attribute__((unavailable("init not available")));
-(NSString*) uniqueKey;
@end




BOOL CheckTable(const unsigned char* tableStart, size_t remaining, NSUInteger section_length);

extern const size_t kPacketHeaderSerializedSizeBytes;
extern const size_t kMinimumTableSizeBytes;

#define kSizeOfATSCPacket 188

NS_ASSUME_NONNULL_END

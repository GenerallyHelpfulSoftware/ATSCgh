//
//  TableExtractor.m
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
//  Created by Glenn Howes on 2/7/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "TableExtractor.h"
#import "ATSCTables.h"
#import "MasterGuideTable.h"
#import "TerrestrialVirtualChannelTable.h"
#import "LanguageString.h"
#import "CableVirtualChannelTable.h"
#import "SystemTimeTable.h"
#import "EventInformationTable.h"
#import "RatingRegionTable.h"
#import "ExtendedTextTable.h"

#define kMaxiumumTableSize  4136

const size_t kPacketHeaderSerializedSizeBytes = 4;
const size_t kMinimumTableSizeBytes = 13;

enum
{
    kMasterGuidTableID = 0xC7,
    kTerrestrialVirtualCannelTableID = 0xc8,
    kCableVirtualChannelTableID = 0xc9,
    kRatingRegionTableID = 0xca,
    kEventInformationTableID = 0xCB,
    kExtendedTextTableID = 0xCC,
    kSystemTimeTable = 0xCD
};



static uint32_t mpeg2_crc_table[256] = {
	0x00000000, 0x04C11DB7, 0x09823B6E, 0x0D4326D9, 0x130476DC, 0x17C56B6B,
	0x1A864DB2, 0x1E475005, 0x2608EDB8, 0x22C9F00F, 0x2F8AD6D6, 0x2B4BCB61,
	0x350C9B64, 0x31CD86D3, 0x3C8EA00A, 0x384FBDBD, 0x4C11DB70, 0x48D0C6C7,
	0x4593E01E, 0x4152FDA9, 0x5F15ADAC, 0x5BD4B01B, 0x569796C2, 0x52568B75,
	0x6A1936C8, 0x6ED82B7F, 0x639B0DA6, 0x675A1011, 0x791D4014, 0x7DDC5DA3,
	0x709F7B7A, 0x745E66CD, 0x9823B6E0, 0x9CE2AB57, 0x91A18D8E, 0x95609039,
	0x8B27C03C, 0x8FE6DD8B, 0x82A5FB52, 0x8664E6E5, 0xBE2B5B58, 0xBAEA46EF,
	0xB7A96036, 0xB3687D81, 0xAD2F2D84, 0xA9EE3033, 0xA4AD16EA, 0xA06C0B5D,
	0xD4326D90, 0xD0F37027, 0xDDB056FE, 0xD9714B49, 0xC7361B4C, 0xC3F706FB,
	0xCEB42022, 0xCA753D95, 0xF23A8028, 0xF6FB9D9F, 0xFBB8BB46, 0xFF79A6F1,
	0xE13EF6F4, 0xE5FFEB43, 0xE8BCCD9A, 0xEC7DD02D, 0x34867077, 0x30476DC0,
	0x3D044B19, 0x39C556AE, 0x278206AB, 0x23431B1C, 0x2E003DC5, 0x2AC12072,
	0x128E9DCF, 0x164F8078, 0x1B0CA6A1, 0x1FCDBB16, 0x018AEB13, 0x054BF6A4,
	0x0808D07D, 0x0CC9CDCA, 0x7897AB07, 0x7C56B6B0, 0x71159069, 0x75D48DDE,
	0x6B93DDDB, 0x6F52C06C, 0x6211E6B5, 0x66D0FB02, 0x5E9F46BF, 0x5A5E5B08,
	0x571D7DD1, 0x53DC6066, 0x4D9B3063, 0x495A2DD4, 0x44190B0D, 0x40D816BA,
	0xACA5C697, 0xA864DB20, 0xA527FDF9, 0xA1E6E04E, 0xBFA1B04B, 0xBB60ADFC,
	0xB6238B25, 0xB2E29692, 0x8AAD2B2F, 0x8E6C3698, 0x832F1041, 0x87EE0DF6,
	0x99A95DF3, 0x9D684044, 0x902B669D, 0x94EA7B2A, 0xE0B41DE7, 0xE4750050,
	0xE9362689, 0xEDF73B3E, 0xF3B06B3B, 0xF771768C, 0xFA325055, 0xFEF34DE2,
	0xC6BCF05F, 0xC27DEDE8, 0xCF3ECB31, 0xCBFFD686, 0xD5B88683, 0xD1799B34,
	0xDC3ABDED, 0xD8FBA05A, 0x690CE0EE, 0x6DCDFD59, 0x608EDB80, 0x644FC637,
	0x7A089632, 0x7EC98B85, 0x738AAD5C, 0x774BB0EB, 0x4F040D56, 0x4BC510E1,
	0x46863638, 0x42472B8F, 0x5C007B8A, 0x58C1663D, 0x558240E4, 0x51435D53,
	0x251D3B9E, 0x21DC2629, 0x2C9F00F0, 0x285E1D47, 0x36194D42, 0x32D850F5,
	0x3F9B762C, 0x3B5A6B9B, 0x0315D626, 0x07D4CB91, 0x0A97ED48, 0x0E56F0FF,
	0x1011A0FA, 0x14D0BD4D, 0x19939B94, 0x1D528623, 0xF12F560E, 0xF5EE4BB9,
	0xF8AD6D60, 0xFC6C70D7, 0xE22B20D2, 0xE6EA3D65, 0xEBA91BBC, 0xEF68060B,
	0xD727BBB6, 0xD3E6A601, 0xDEA580D8, 0xDA649D6F, 0xC423CD6A, 0xC0E2D0DD,
	0xCDA1F604, 0xC960EBB3, 0xBD3E8D7E, 0xB9FF90C9, 0xB4BCB610, 0xB07DABA7,
	0xAE3AFBA2, 0xAAFBE615, 0xA7B8C0CC, 0xA379DD7B, 0x9B3660C6, 0x9FF77D71,
	0x92B45BA8, 0x9675461F, 0x8832161A, 0x8CF30BAD, 0x81B02D74, 0x857130C3,
	0x5D8A9099, 0x594B8D2E, 0x5408ABF7, 0x50C9B640, 0x4E8EE645, 0x4A4FFBF2,
	0x470CDD2B, 0x43CDC09C, 0x7B827D21, 0x7F436096, 0x7200464F, 0x76C15BF8,
	0x68860BFD, 0x6C47164A, 0x61043093, 0x65C52D24, 0x119B4BE9, 0x155A565E,
	0x18197087, 0x1CD86D30, 0x029F3D35, 0x065E2082, 0x0B1D065B, 0x0FDC1BEC,
	0x3793A651, 0x3352BBE6, 0x3E119D3F, 0x3AD08088, 0x2497D08D, 0x2056CD3A,
	0x2D15EBE3, 0x29D4F654, 0xC5A92679, 0xC1683BCE, 0xCC2B1D17, 0xC8EA00A0,
	0xD6AD50A5, 0xD26C4D12, 0xDF2F6BCB, 0xDBEE767C, 0xE3A1CBC1, 0xE760D676,
	0xEA23F0AF, 0xEEE2ED18, 0xF0A5BD1D, 0xF464A0AA, 0xF9278673, 0xFDE69BC4,
	0x89B8FD09, 0x8D79E0BE, 0x803AC667, 0x84FBDBD0, 0x9ABC8BD5, 0x9E7D9662,
	0x933EB0BB, 0x97FFAD0C, 0xAFB010B1, 0xAB710D06, 0xA6322BDF, 0xA2F33668,
	0xBCB4666D, 0xB8757BDA, 0xB5365D03, 0xB1F740B4
};

uint32_t mpeg2_crc_calculate(const uint8_t *start, const uint8_t *end)
{
	const uint8_t *ptr = start;
	uint32_t crc = 0xFFFFFFFF;
    
	while (ptr < end) {
		crc = (crc << 8) ^ mpeg2_crc_table[(crc >> 24) ^ *ptr++];
	}
    
	return crc;
}

PacketHeader ExtractPacketHeaderFromData(const unsigned char* packetStart)
{
    PacketHeader result;
    unsigned char byte0 = packetStart[0];
    unsigned char byte1 = packetStart[1];
    unsigned char byte2 = packetStart[2];
    
    result.transportErrorIndicator = byte0 >> 7;
    result.payloadUnitStart = 1 & (byte0 >> 6);
    result.transportPriority = 1 & (byte0 >> 5);
    result.packetID = ((byte0 & 0x1f)<<8) | byte1;
    result.scramblingControl = (ScramblingState) (byte2 >> 6);
    result.adaptationFieldExists = 1 & (byte2 >> 5);
    result.containsPayload = 1 & (byte2 >> 4);
    result.continuityCounter = ( 15 & byte2);
    
    return result;
}



TableHeader ExtractTableHeaderFromData(const unsigned char* tableStart)
{
    TableHeader result;
    unsigned char byte1 = tableStart[1]; // tableStart[0] is apparently always? 0?
    unsigned char byte2 = tableStart[2];
    unsigned char byte3 = tableStart[3];
    unsigned char byte4 = tableStart[4];
    unsigned char byte5 = tableStart[5];
    unsigned char byte6 = tableStart[6];
    
    result.table_id = byte1;
    result.section_syntax_indicator = byte2 >> 7;
    result.private_indicator = 1 & (byte2 >> 6);
    result.section_length = ((byte2 & 15)<<8) | byte3;
    result.table_id_extension = (byte4 <<8) | byte5;
    result.version_number = 31 & (byte6 >> 1);
    result.current_next_indicator = 1 & byte6;
    result.section_number = tableStart[7];
    result.last_section_number = tableStart[8];
    result.protocol_version = tableStart[9];
    
    
    return result;
}

BOOL CheckTable(const unsigned char* tableStart, size_t remaining, NSUInteger section_length)
{
    BOOL result = NO;
    
    NSUInteger lengthOfTable = section_length+1+2; // 1 byte before the section_length header, 2 bytes for the section length
    if(lengthOfTable <= remaining)
    {
        const unsigned char* crcPtr = &tableStart[lengthOfTable-4];
        uint32_t    calculatedCRC = mpeg2_crc_calculate(tableStart, crcPtr);
        uint32_t    embeddedCRC = crcPtr[0] <<24L | crcPtr[1] << 16L | crcPtr[2] << 8L | crcPtr[3];
        if(calculatedCRC == embeddedCRC)
        {
            result = YES;
        }
    }
    
    return result;
    
}

@interface TableExtractor()
{
    NSMutableData*  buffer;
    NSUInteger      section_length;
    NSUInteger      accumulated_section_length;
    PacketHeader    packetHeader;
    TableHeader     tableHeader;
}

@end

@implementation TableExtractor

-(id) initWithPID:(NSNumber*)aPid
{
    if(nil != (self = [super init]))
    {
        _pid = aPid;
        buffer = [[NSMutableData alloc] initWithLength:kMaxiumumTableSize];
    }
    return self;
}

-(NSUInteger) hash
{
    return self.pid.hash;
}


-(BOOL)isEqual:(id)object
{
    BOOL result = NO;
    if([object isKindOfClass:[self class]])
    {
        result = [self.pid isEqual:[(TableExtractor*)object pid]];
    }
    return result;
}


-(void) extractTableFromData:(const unsigned char*)rawDataPtr ofValidLength:(size_t)byteCount withPacketHeader:(const PacketHeader*)aPacketHeader intoTableDictionary:(NSMutableDictionary*)tables
{
    NSUInteger index = 3;
    if(byteCount > (kSizeOfATSCPacket-1)) byteCount = kSizeOfATSCPacket-1;
    NSInteger remainingData = byteCount-index;
    if(remainingData > 0 && aPacketHeader->adaptationFieldExists)
    {
        unsigned char adaptationLength = rawDataPtr[index++];
        index+= adaptationLength;
        remainingData = byteCount-index;
    }
    if(aPacketHeader->payloadUnitStart)
    {
        tableHeader = ExtractTableHeaderFromData(&rawDataPtr[index]);
        _table_id = tableHeader.table_id;
        packetHeader = *aPacketHeader;
        section_length = tableHeader.section_length;
        accumulated_section_length = 0;
        index = 4;
        remainingData = byteCount-index;
    }
    
    unsigned char* destBuffer = buffer.mutableBytes+accumulated_section_length;
    if(_table_id >= kMasterGuidTableID && _table_id <= kSystemTimeTable)
    {
        if(remainingData > 0 && aPacketHeader->containsPayload)
        {
            memcpy(destBuffer, &rawDataPtr[index], remainingData);
            accumulated_section_length += remainingData;
            if(accumulated_section_length >= (section_length+3))// room for the CRC + the actual section data
            {
                if(CheckTable(buffer.mutableBytes, accumulated_section_length, section_length)) // check the CRC
                {
                    Class tableClass = nil;
                    
                    switch(_table_id)
                    {
                        case kMasterGuidTableID:
                        {
                            tableClass = [MasterGuideTable class];
                        }
                        break;
                        case kTerrestrialVirtualCannelTableID:
                        {
                            tableClass = [TerrestrialVirtualChannelTable class];
                        }
                        break;
                        case kCableVirtualChannelTableID:
                        {
                            tableClass = [CableVirtualChannelTable class];
                        }
                        break;
                        case kRatingRegionTableID:
                        {
                            tableClass = [RatingRegionTable class];
                        }
                        break;
                        case kEventInformationTableID:
                        {
                            tableClass = [EventInformationTable class];
                        }
                        break;
                        case kExtendedTextTableID:
                        {
                            tableClass = [ExtendedTextTable class];
                        }
                        break;
                            
                        case kSystemTimeTable:
                        {
                            tableClass = [SystemTimeTable class];
                        }
                        break;
                    }
                    ATSCTable* aTable = [[tableClass alloc] initWithTableHeader:tableHeader packetHeader:packetHeader rawData:buffer.mutableBytes];
                    [tables setObject:aTable forKey:aTable.uniqueKey];
                }
                else
                {
                    CheckTable(buffer.mutableBytes, accumulated_section_length, section_length);
                }
                accumulated_section_length = 0;
                _table_id = 0;
                
            }
        }
    }
}

+(void) extractTablesFromData:(const unsigned char*)rawDataPtr ofValidLength:(size_t)validLength withSetOfExtractors:(NSDictionary*)preexisting intoCallback:(parsingCallback_t)callback
{
    NSUInteger byteCount = validLength;
    NSMutableDictionary* tables = [[NSMutableDictionary alloc] initWithCapacity:128];
    NSUInteger index = 0;
    NSDictionary* pids = [preexisting copy];
    
    if(byteCount >= kPacketHeaderSerializedSizeBytes)
    {
        BOOL    foundSyncByte = NO;
        while(!foundSyncByte)
        {
            do {
                char aByte = rawDataPtr[index++];
                if(aByte == 'G')
                {
                    foundSyncByte = YES;
                }
                
            } while (byteCount > (index+kPacketHeaderSerializedSizeBytes) && !foundSyncByte);
            
            
            if(foundSyncByte)
            {
                foundSyncByte = NO;
                PacketHeader packetHeader = ExtractPacketHeaderFromData(&rawDataPtr[index]);
                if(!packetHeader.transportErrorIndicator)
                {
                    NSNumber* pidNumber = [[NSNumber alloc] initWithInt:packetHeader.packetID];
                    TableExtractor* theExtractor = [pids objectForKey:pidNumber];
                    if(theExtractor == nil)
                    {
                        theExtractor = [[TableExtractor alloc] initWithPID:pidNumber];
                        NSMutableDictionary* newPids = (pids==nil)?[[NSMutableDictionary alloc] initWithCapacity:128]:[pids mutableCopy];
                        
                        [newPids setObject:theExtractor forKey:pidNumber];
                        pids = [newPids copy];
                    }
                    [theExtractor extractTableFromData:&rawDataPtr[index] ofValidLength:validLength-index withPacketHeader:&packetHeader intoTableDictionary:tables];
                    index += (kSizeOfATSCPacket-1);
                }
            }
            else
            {
                break;
            }
            if(byteCount <= (index+kPacketHeaderSerializedSizeBytes))
            {
                break;
            }
        }
    }
    callback(index, [pids copy], [tables copy]);
}
@end

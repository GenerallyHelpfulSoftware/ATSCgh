//
//  ATSC_Tests.m
//  HDHomerun Tests
//
//  Created by Glenn Howes on 1/3/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MasterGuideTable.h"
#import "NSData+DigitalTV.h"
#import "TerrestrialVirtualChannelTable.h"
#import "SystemTimeTable.h"
#import "TableExtractor.h"
#import "NSData+DigitalTV.h"
#import "NSString+DigitalTV.h"
#import "LanguageString.h"
#import "EventInformationTable.h"
NSString* const kTestFileDirectoryName = @"TestFiles";

@interface ATSC_Tests : XCTestCase

@end

@implementation ATSC_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void) testGetNthBit
{
    unsigned char   testData[] = {0xFF, 0x00, 0x80, 0x01};
    BOOL bitSet = GetNthBitOfMemory(5, &testData[0]);
    XCTAssertTrue(bitSet, @"Assumed Bit was true");
    bitSet = GetNthBitOfMemory(11, &testData[0]);
    XCTAssertFalse(bitSet, @"Assumed Bit was false");
    bitSet = GetNthBitOfMemory(16, &testData[0]);
    XCTAssertTrue(bitSet, @"Assumed Bit was true");
    bitSet = GetNthBitOfMemory(18, &testData[0]);
    XCTAssertFalse(bitSet, @"Assumed Bit was false");
    bitSet = GetNthBitOfMemory(31, &testData[0]);
    XCTAssertTrue(bitSet, @"Assumed Bit was true");
}

-(void) testHuffman
{
    const char c4C5Data[] = "\xF1\xE7\xDF\x94\x2B\x60\xD7\x00";
    size_t length = (sizeof c4C5Data) - 1;
    NSData *testData = [NSData dataWithBytes:c4C5Data length:length];
    testData = [testData dataAfterUncompressionUsingTablesC5];
    NSString* testString = [NSString stringFromData:testData withFirstByte:0];
    XCTAssertEqualObjects(testString, @"Paper Crafting", @"Expected 'Paper Crafting' got %@", testString);
    
    const char rocky[] = "\xD3\x86\x32\x58";
    length = (sizeof rocky) - 1;
    testData = [NSData dataWithBytes:rocky length:length];
    testData = [testData dataAfterUncompressionUsingTablesC5];
    testString = [NSString stringFromData:testData withFirstByte:0];
    XCTAssertEqualObjects(testString, @"Rocky V", @"Expected 'Rocky V' got %@", testString);
}

-(void) testTime
{
    NSTimeInterval aTimeAfter1980 = 1076196616; // seconds after a date in 1980
    NSTimeInterval beginningOf1980 = [SystemTimeTable beginningOf1980];
    XCTAssertTrue(beginningOf1980 == 315982800, @"Expected a different value for the time from 1970 to 1980");
    
    NSTimeZone* myTimeZone = [NSTimeZone timeZoneWithName:@"America/New_York"];
    NSInteger secondsOffGMT = [myTimeZone secondsFromGMT];
    
    NSTimeInterval aTimeAfter1970 = beginningOf1980+aTimeAfter1980+secondsOffGMT;
    NSDate* aDate = [NSDate dateWithTimeIntervalSince1970:aTimeAfter1970];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:aDate];
    
    XCTAssertTrue(components.year == 2014, @"Expected a different year than:%ld", (long)components.year);
    XCTAssertTrue(components.month == 2, @"Expected a different month than:%ld", (long)components.month);
}

-(void) testMasterTableParse
{
    NSString* bundleResourcePath = [[NSBundle bundleForClass:[self class]] resourcePath];
    NSString* pathToTestFiles = [bundleResourcePath stringByAppendingPathComponent:kTestFileDirectoryName];
    NSString* pathToMGTCaptureTestFile = [pathToTestFiles stringByAppendingPathComponent:@"capture_mgt.ts"];
    
    NSData* mgtTestData = [NSData dataWithContentsOfFile:pathToMGTCaptureTestFile];
    XCTAssertNotNil(mgtTestData, @"Missing Test Data: %@", pathToMGTCaptureTestFile);
    __block NSDictionary* extractedTables = nil;
    __block NSDictionary* extractors = [[NSDictionary alloc] init];
    [TableExtractor extractTablesFromData:mgtTestData.bytes ofValidLength:mgtTestData.length withSetOfExtractors:extractors intoCallback:^(NSUInteger endIndex, NSDictionary* newExtractors, NSDictionary* tables) {
        extractors = newExtractors;
        
        extractedTables = tables;
    }];
    
    XCTAssertNotNil(extractedTables, @"Expected to find tables");
    BOOL foundEIT = NO;
    BOOL foundExtendedText = NO;
    BOOL foundTerrestrialChannels = NO;
    BOOL foundSystemTime = NO;
    
    for(ATSCTable* aTable in extractedTables.allValues)
    {
        XCTAssertTrue([aTable isKindOfClass:[ATSCTable class]], @"Expected an ATSCTable, got: %@", NSStringFromClass([aTable class]));
        
        if([aTable isKindOfClass:[MasterGuideTable class]])
        {
            MasterGuideTable* tableAsMasterGuideTable = (MasterGuideTable*)aTable;
            NSDictionary* tableDefinitions = tableAsMasterGuideTable.tableDefinitions;
            
            XCTAssertFalse(tableDefinitions.count == 0, @"Found Empty Master Guide Table");
            for(NSDictionary* aTableDefinition in tableDefinitions.allValues)
            {
                TableDefinitionType type = (TableDefinitionType)[[aTableDefinition objectForKey:kTableTypeDefinitionKey] intValue];
                if(type == kEventInformationTableDefinition)
                {
                    foundEIT = YES;
                }
                else if(type == kExtendedEventTextTableDefinition)
                {
                    foundExtendedText = YES;
                }
                else if(type == kTerrestrialVCTTableDefinition)
                {
                }
            }
        }
        else if([aTable isKindOfClass:[TerrestrialVirtualChannelTable class]])
        {
            TerrestrialVirtualChannelTable* terrestrialTable = (TerrestrialVirtualChannelTable*)aTable;
            foundTerrestrialChannels = YES;
            NSUInteger channelCount = terrestrialTable.channels.count;
            XCTAssertTrue(channelCount == 1, @"Expected 1 Channel");
            if(channelCount)
            {
                TerrestrialVirtualChannel* theChannel = terrestrialTable.channels[0];
                XCTAssertEqualObjects(@"WBZ-TV", theChannel.short_name, @"Expected Channel Named WBZ-TV, Got: %@", theChannel.short_name);
                
                XCTAssertTrue(theChannel.major_channel_number == 4, @"Expected major_channel_number 4, got: %hd", theChannel.major_channel_number);
                XCTAssertTrue(theChannel.minor_channel_number == 1, @"Expected minor_channel_number 1, got: %hd", theChannel.minor_channel_number);
                XCTAssertTrue(theChannel.service_type ==  kATSCServiceTypeDigitalTV, @"Expected serviceType was digital TV, got: %d",
                              theChannel.service_type);
            }
            
        }
        else if([aTable isKindOfClass:[SystemTimeTable class]])
        {
            SystemTimeTable* timeTable = (SystemTimeTable*) aTable;
            
            XCTAssertTrue(timeTable.UTCOffset == 15, @"Expected UTCOffset 15, got: %d", timeTable.UTCOffset);
            
            foundSystemTime = YES;
        }
    }
    
    XCTAssertTrue(foundEIT, @"Didn't find an EIT Definition");
    XCTAssertTrue(foundExtendedText, @"Didn't find Extended Text Definition");
    XCTAssertTrue(foundTerrestrialChannels, @"Didn't find Terrestrial Channels");
    XCTAssertTrue(foundSystemTime, @"Didn't find SystemTime");
}

-(void) testFoxTableParse
{
    NSString* bundleResourcePath = [[NSBundle bundleForClass:[self class]] resourcePath];
    NSString* pathToTestFiles = [bundleResourcePath stringByAppendingPathComponent:kTestFileDirectoryName];
    NSString* pathToMGTCaptureTestFile = [pathToTestFiles stringByAppendingPathComponent:@"capture_fox.ts"];
    
    NSData* mgtTestData = [NSData dataWithContentsOfFile:pathToMGTCaptureTestFile];
    XCTAssertNotNil(mgtTestData, @"Missing Test Data: %@", pathToMGTCaptureTestFile);
    __block NSDictionary* extractedTables = nil;
    __block NSDictionary* extractors = [[NSDictionary alloc] init];
    [TableExtractor extractTablesFromData:mgtTestData.bytes ofValidLength:mgtTestData.length withSetOfExtractors:extractors intoCallback:^(NSUInteger endIndex, NSDictionary* newExtractors, NSDictionary* tables) {
        extractors = newExtractors;
        
        extractedTables = tables;
    }];
    
    XCTAssertNotNil(extractedTables, @"Expected to find tables");
    BOOL foundEIT = NO;
    BOOL foundExtendedText = NO;
    BOOL foundTerrestrialChannels = NO;
    BOOL foundSystemTime = NO;
    
    for(ATSCTable* aTable in extractedTables.allValues)
    {
        XCTAssertTrue([aTable isKindOfClass:[ATSCTable class]], @"Expected an ATSCTable, got: %@", NSStringFromClass([aTable class]));
        
        if([aTable isKindOfClass:[MasterGuideTable class]])
        {
            MasterGuideTable* tableAsMasterGuideTable = (MasterGuideTable*)aTable;
            NSDictionary* tableDefinitions = tableAsMasterGuideTable.tableDefinitions;
            
            XCTAssertFalse(tableDefinitions.count == 0, @"Found Empty Master Guide Table");
            for(NSDictionary* aTableDefinition in tableDefinitions.allValues)
            {
                TableDefinitionType type = (TableDefinitionType)[[aTableDefinition objectForKey:kTableTypeDefinitionKey] intValue];
                if(type == kEventInformationTableDefinition)
                {
                    foundEIT = YES;
                }
                else if(type == kExtendedEventTextTableDefinition)
                {
                    foundExtendedText = YES;
                }
                else if(type == kTerrestrialVCTTableDefinition)
                {
                }
            }
        }
        else if([aTable isKindOfClass:[TerrestrialVirtualChannelTable class]])
        {
            TerrestrialVirtualChannelTable* terrestrialTable = (TerrestrialVirtualChannelTable*)aTable;
            foundTerrestrialChannels = YES;
            NSUInteger channelCount = terrestrialTable.channels.count;
            XCTAssertTrue(channelCount == 2, @"Expected 1 Channel");
            if(channelCount)
            {
                TerrestrialVirtualChannel* theChannel = terrestrialTable.channels[0];
                XCTAssertEqualObjects(@"WFXT DT", theChannel.short_name, @"Expected Channel Named WFXT DT, Got: %@", theChannel.short_name);
                
                XCTAssertTrue(theChannel.major_channel_number == 25, @"Expected major_channel_number 25, got: %hd", theChannel.major_channel_number);
                XCTAssertTrue(theChannel.minor_channel_number == 1, @"Expected minor_channel_number 1, got: %hd", theChannel.minor_channel_number);
                XCTAssertTrue(theChannel.service_type ==  kATSCServiceTypeDigitalTV, @"Expected serviceType was digital TV, got: %d",
                              theChannel.service_type);
                
            }
            if(channelCount >= 2)
            {
                TerrestrialVirtualChannel* theChannel = terrestrialTable.channels[1];
                XCTAssertEqualObjects(@"WFXT DT", theChannel.short_name, @"Expected Channel Named WFXT DT, Got: %@", theChannel.short_name);
                
                XCTAssertTrue(theChannel.major_channel_number == 25, @"Expected major_channel_number 25, got: %hd", theChannel.major_channel_number);
                XCTAssertTrue(theChannel.minor_channel_number == 2, @"Expected minor_channel_number 2, got: %hd", theChannel.minor_channel_number);
                XCTAssertTrue(theChannel.service_type ==  kATSCServiceTypeDigitalTV, @"Expected serviceType was digital TV, got: %d",
                              theChannel.service_type);
            }
            
        }
        else if([aTable isKindOfClass:[SystemTimeTable class]])
        {
            SystemTimeTable* timeTable = (SystemTimeTable*) aTable;
            
            XCTAssertTrue(timeTable.UTCOffset == 15, @"Expected UTCOffset 15, got: %d", timeTable.UTCOffset);
            
            foundSystemTime = YES;
        }
    }
    
    XCTAssertTrue(foundEIT, @"Didn't find an EIT Definition");
    XCTAssertTrue(foundExtendedText, @"Didn't find Extended Text Definition");
    XCTAssertTrue(foundTerrestrialChannels, @"Didn't find Terrestrial Channels");
    XCTAssertTrue(foundSystemTime, @"Didn't find SystemTime");
}

-(void) testWGBH_MGTableParse
{
    NSString* bundleResourcePath = [[NSBundle bundleForClass:[self class]] resourcePath];
    NSString* pathToTestFiles = [bundleResourcePath stringByAppendingPathComponent:kTestFileDirectoryName];
    NSString* pathToMGTCaptureTestFile = [pathToTestFiles stringByAppendingPathComponent:@"capture_wgbh_mgt.ts"];
    
    NSData* mgtTestData = [NSData dataWithContentsOfFile:pathToMGTCaptureTestFile];
    XCTAssertNotNil(mgtTestData, @"Missing Test Data: %@", pathToMGTCaptureTestFile);
    __block NSDictionary* extractedTables = nil;
    
    __block NSDictionary* extractors = [[NSDictionary alloc] init];
    [TableExtractor extractTablesFromData:mgtTestData.bytes ofValidLength:mgtTestData.length withSetOfExtractors:extractors intoCallback:^(NSUInteger endIndex, NSDictionary* newExtractors, NSDictionary* tables) {
        extractors = newExtractors;
        
        extractedTables = tables;
    }];
    
    XCTAssertNotNil(extractedTables, @"Expected to find tables");
    BOOL foundEIT = NO;
    BOOL foundExtendedText = NO;
    BOOL foundTerrestrialChannels = NO;
    BOOL foundSystemTime = NO;
    
    for(ATSCTable* aTable in extractedTables.allValues)
    {
        XCTAssertTrue([aTable isKindOfClass:[ATSCTable class]], @"Expected an ATSCTable, got: %@", NSStringFromClass([aTable class]));
        
        if([aTable isKindOfClass:[MasterGuideTable class]])
        {
            MasterGuideTable* tableAsMasterGuideTable = (MasterGuideTable*)aTable;
            NSDictionary* tableDefinitions = tableAsMasterGuideTable.tableDefinitions;
            
            XCTAssertFalse(tableDefinitions.count == 0, @"Found Empty Master Guide Table");
            for(NSDictionary* aTableDefinition in tableDefinitions.allValues)
            {
                TableDefinitionType type = (TableDefinitionType)[[aTableDefinition objectForKey:kTableTypeDefinitionKey] intValue];
                if(type == kEventInformationTableDefinition)
                {
                    foundEIT = YES;
                }
                else if(type == kExtendedEventTextTableDefinition)
                {
                    foundExtendedText = YES;
                }
                else if(type == kTerrestrialVCTTableDefinition)
                {
                }
            }
        }
        else if([aTable isKindOfClass:[TerrestrialVirtualChannelTable class]])
        {
            TerrestrialVirtualChannelTable* terrestrialTable = (TerrestrialVirtualChannelTable*)aTable;
            foundTerrestrialChannels = YES;
            NSUInteger channelCount = terrestrialTable.channels.count;
            XCTAssertTrue(channelCount == 4, @"Expected 2 Channel");
            if(channelCount)
            {
                TerrestrialVirtualChannel* theChannel = terrestrialTable.channels[0];
                XCTAssertEqualObjects(@"WGBH HD", theChannel.short_name, @"Expected Channel Named WGBH HD, Got: %@", theChannel.short_name);
                
                XCTAssertTrue(theChannel.major_channel_number == 2, @"Expected major_channel_number 2, got: %hd", theChannel.major_channel_number);
                XCTAssertTrue(theChannel.minor_channel_number == 1, @"Expected minor_channel_number 1, got: %hd", theChannel.minor_channel_number);
                XCTAssertTrue(theChannel.service_type ==  kATSCServiceTypeDigitalTV, @"Expected serviceType was digital TV, got: %d",
                              theChannel.service_type);
                
            }
            if(channelCount >= 2)
            {
                TerrestrialVirtualChannel* theChannel = terrestrialTable.channels[1];
                XCTAssertEqualObjects(@"World", theChannel.short_name, @"Expected Channel Named World, Got: %@", theChannel.short_name);
                
                XCTAssertTrue(theChannel.major_channel_number == 2, @"Expected major_channel_number 2, got: %hd", theChannel.major_channel_number);
                XCTAssertTrue(theChannel.minor_channel_number == 2, @"Expected minor_channel_number 2, got: %hd", theChannel.minor_channel_number);
                XCTAssertTrue(theChannel.service_type ==  kATSCServiceTypeDigitalTV, @"Expected serviceType was digital TV, got: %d",
                              theChannel.service_type);
            }
            
        }
        else if([aTable isKindOfClass:[SystemTimeTable class]])
        {
            SystemTimeTable* timeTable = (SystemTimeTable*) aTable;
            
            XCTAssertTrue(timeTable.UTCOffset == 15, @"Expected UTCOffset 15, got: %d", timeTable.UTCOffset);
            
            foundSystemTime = YES;
        }
    }
    
    XCTAssertTrue(foundEIT, @"Didn't find an EIT Definition");
    XCTAssertTrue(foundExtendedText, @"Didn't find Extended Text Definition");
    XCTAssertTrue(foundTerrestrialChannels, @"Didn't find Terrestrial Channels");
    XCTAssertTrue(foundSystemTime, @"Didn't find SystemTime");
}

-(void) testNBC_MGTableParse
{
    NSString* bundleResourcePath = [[NSBundle bundleForClass:[self class]] resourcePath];
    NSString* pathToTestFiles = [bundleResourcePath stringByAppendingPathComponent:kTestFileDirectoryName];
    NSString* pathToMGTCaptureTestFile = [pathToTestFiles stringByAppendingPathComponent:@"capture_nbc_mgt.ts"];
    
    NSData* mgtTestData = [NSData dataWithContentsOfFile:pathToMGTCaptureTestFile];
    XCTAssertNotNil(mgtTestData, @"Missing Test Data: %@", pathToMGTCaptureTestFile);
    __block NSDictionary* extractedTables = nil;
    __block NSDictionary* extractors = [[NSDictionary alloc] init];
    [TableExtractor extractTablesFromData:mgtTestData.bytes ofValidLength:mgtTestData.length withSetOfExtractors:extractors intoCallback:^(NSUInteger endIndex, NSDictionary* newExtractors, NSDictionary* tables) {
        extractors = newExtractors;
        
        extractedTables = tables;
    }];
    
    XCTAssertNotNil(extractedTables, @"Expected to find tables");
    BOOL foundEIT = NO;
    BOOL foundExtendedText = NO;
    BOOL foundTerrestrialChannels = NO;
    BOOL foundSystemTime = NO;
    
    for(ATSCTable* aTable in extractedTables.allValues)
    {
        XCTAssertTrue([aTable isKindOfClass:[ATSCTable class]], @"Expected an ATSCTable, got: %@", NSStringFromClass([aTable class]));
        
        if([aTable isKindOfClass:[MasterGuideTable class]])
        {
            MasterGuideTable* tableAsMasterGuideTable = (MasterGuideTable*)aTable;
            NSDictionary* tableDefinitions = tableAsMasterGuideTable.tableDefinitions;
            
            XCTAssertFalse(tableDefinitions.count == 0, @"Found Empty Master Guide Table");
            for(NSDictionary* aTableDefinition in tableDefinitions.allValues)
            {
                TableDefinitionType type = (TableDefinitionType)[[aTableDefinition objectForKey:kTableTypeDefinitionKey] intValue];
                if(type == kEventInformationTableDefinition)
                {
                    foundEIT = YES;
                }
                else if(type == kExtendedEventTextTableDefinition)
                {
                    foundExtendedText = YES;
                }
                else if(type == kTerrestrialVCTTableDefinition)
                {
                }
            }
        }
        else if([aTable isKindOfClass:[TerrestrialVirtualChannelTable class]])
        {
            TerrestrialVirtualChannelTable* terrestrialTable = (TerrestrialVirtualChannelTable*)aTable;
            foundTerrestrialChannels = YES;
            NSUInteger channelCount = terrestrialTable.channels.count;
            XCTAssertTrue(channelCount == 2, @"Expected 2 Channel");
            if(channelCount)
            {
                TerrestrialVirtualChannel* theChannel = terrestrialTable.channels[0];
                XCTAssertEqualObjects(@"WHDH-HD", theChannel.short_name, @"Expected Channel Named WHDH-HD, Got: %@", theChannel.short_name);
                
                XCTAssertTrue(theChannel.major_channel_number == 7, @"Expected major_channel_number 7, got: %hd", theChannel.major_channel_number);
                XCTAssertTrue(theChannel.minor_channel_number == 1, @"Expected minor_channel_number 1, got: %hd", theChannel.minor_channel_number);
                XCTAssertTrue(theChannel.service_type ==  kATSCServiceTypeDigitalTV, @"Expected serviceType was digital TV, got: %d",
                              theChannel.service_type);
                
            }
            if(channelCount >= 2)
            {
                TerrestrialVirtualChannel* theChannel = terrestrialTable.channels[1];
                XCTAssertEqualObjects(@"This TV", theChannel.short_name, @"Expected Channel Named This TV, Got: %@", theChannel.short_name);
                
                XCTAssertTrue(theChannel.major_channel_number == 7, @"Expected major_channel_number 7, got: %hd", theChannel.major_channel_number);
                XCTAssertTrue(theChannel.minor_channel_number == 2, @"Expected minor_channel_number 2, got: %hd", theChannel.minor_channel_number);
                XCTAssertTrue(theChannel.service_type ==  kATSCServiceTypeDigitalTV, @"Expected serviceType was digital TV, got: %d",
                              theChannel.service_type);
            }
            
        }
        else if([aTable isKindOfClass:[SystemTimeTable class]])
        {
            SystemTimeTable* timeTable = (SystemTimeTable*) aTable;
            
            XCTAssertTrue(timeTable.UTCOffset == 15, @"Expected UTCOffset 15, got: %d", timeTable.UTCOffset);
            
            foundSystemTime = YES;
        }
    }
    
    XCTAssertTrue(foundEIT, @"Didn't find an EIT Definition");
    XCTAssertTrue(foundExtendedText, @"Didn't find Extended Text Definition");
    XCTAssertTrue(foundTerrestrialChannels, @"Didn't find Terrestrial Channels");
    XCTAssertTrue(foundSystemTime, @"Didn't find SystemTime");
}

-(void) testEventInformationTables
{
    NSString* bundleResourcePath = [[NSBundle bundleForClass:[self class]] resourcePath];
    NSString* pathToTestFiles = [bundleResourcePath stringByAppendingPathComponent:kTestFileDirectoryName];
    NSString* pathToEITTablesRawData = [pathToTestFiles stringByAppendingPathComponent:@"capture_wgbh_tables.ts"];
    
    NSData* tablesTestData = [NSData dataWithContentsOfFile:pathToEITTablesRawData];
    XCTAssertNotNil(tablesTestData, @"Missing EIT Test Data: %@", pathToEITTablesRawData);
    __block NSDictionary* extractedTables = nil;
 __block NSDictionary* extractors = [[NSDictionary alloc] init];
     [TableExtractor extractTablesFromData:tablesTestData.bytes ofValidLength:tablesTestData.length withSetOfExtractors:extractors intoCallback:^(NSUInteger endIndex, NSDictionary* newExtractors, NSDictionary* tables) {
     extractors = newExtractors;
     
     extractedTables = tables;
     }];
 
    XCTAssertNotNil(extractedTables, @"Didn't extract any EIT tables: %@", pathToEITTablesRawData);
    
    XCTAssertTrue(extractedTables.count == 32, @"Extracted an unexpected number of EIT tables:%lu", (unsigned long)extractedTables.count);
    
    for(ATSCTable* aTable in extractedTables.allValues)
    {
        if([aTable isKindOfClass:[EventInformationTable class]])
        {
            EventInformationTable* eventTable = (EventInformationTable*)aTable;
            XCTAssertTrue([eventTable isKindOfClass:[EventInformationTable class]], @"Extracted an kind of table instead of EventInformationTable:%@", NSStringFromClass(aTable.class));
            if([eventTable isKindOfClass:[EventInformationTable class]])
            {
                BOOL hasEnglish = NO;
                XCTAssertTrue(eventTable.records.count > 0, @"EventInformationTable has no records");
                for(EventInformationRecord* aRecord in eventTable.records)
                {
                    for(LanguageString* aString in aRecord.titles)
                    {
                        if([aString.languageCode isEqualToString:@"eng"])
                        {
                            hasEnglish = YES;
                        }
                        NSString* theText = aString.string;
                        
                        XCTAssertTrue(theText.length, @"Found zero length text in EIT Title");
                    }
                }
                
                XCTAssertTrue(hasEnglish, @"Didn't find 'eng' as language code");
            }
        }
    }
    
}

/*
-(void) testExtendedTextTables
{
    NSString* bundleResourcePath = [[NSBundle bundleForClass:[self class]] resourcePath];
    NSString* pathToTestFiles = [bundleResourcePath stringByAppendingPathComponent:kTestFileDirectoryName];
    NSString* pathToEITTablesRawData = [pathToTestFiles stringByAppendingPathComponent:@"capture_tables.ts"];
    
    NSData* tablesTestData = [NSData dataWithContentsOfFile:pathToEITTablesRawData];
    XCTAssertNotNil(tablesTestData, @"Missing Test Data: %@", pathToEITTablesRawData);
    __block NSDictionary* extractedTables = nil;
 __block NSDictionary* extractors = [[NSDictionary alloc] init];
 [TableExtractor extractTablesFromData:mgtTestData.bytes ofValidLength:mgtTestData.length withSetOfExtractors:extractors intoCallback:^(NSUInteger endIndex, NSDictionary* newExtractors, NSDictionary* tables) {
 extractors = newExtractors;
 
 extractedTables = tables;
 }];
    XCTAssertNotNil(extractedTables, @"Didn't extract any tables: %@", pathToEITTablesRawData);
    
    XCTAssertTrue(extractedTables.count == 77, @"Extracted an unexpected number of tables:%d", extractedTables.count);
    
    for(ATSCTable* aTable in extractedTables.allValues)
    {
        ExtendedTextTable* extendedTextTable = (ExtendedTextTable*)aTable;
        
        XCTAssertTrue([extendedTextTable isKindOfClass:[ExtendedTextTable class]], @"Extracted an kind of table instead of EventInformationTable:%@", NSStringFromClass(aTable.class));
        if([extendedTextTable isKindOfClass:[ExtendedTextTable class]])
        {
            BOOL hasEnglish = NO;
            for(LanguageString* aString in extendedTextTable.strings)
            {
                if([aString.languageCode isEqualToString:@"eng"])
                {
                    hasEnglish = YES;
                }
                NSString* theText = aString.string;
                
                XCTAssertTrue(theText.length, @"Found zero length text in ETT");
            }
            
            XCTAssertTrue(hasEnglish, @"Didn't find 'eng' as language code");
        }
    }
    
}
 */
@end

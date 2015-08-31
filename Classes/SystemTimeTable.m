//
//  SystemTimeTable.m
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "SystemTimeTable.h"

@interface SystemTimeTable()
@property(nonatomic, assign) NSUInteger secondsSinceJanuary_6_1980;
@property(nonatomic, assign) BOOL inDaylightSavingsTime;
@property(nonatomic, assign) unsigned char  UTCOffset;
@property(nonatomic, assign) unsigned char  dayOfMonthForDaylightSavingsTransition;
@property(nonatomic, assign) unsigned char  hourForDaylightSavingsTransition;

@end

@implementation SystemTimeTable

+(NSDate*) dateOf1980
{
    static NSDate* sResult = nil;
    static dispatch_once_t  done;
    dispatch_once(&done, ^{
        NSTimeInterval beginningOf1980 = [self beginningOf1980];
        sResult = [[NSDate alloc] initWithTimeIntervalSince1970:beginningOf1980];
    });
    return sResult;
}

+(NSTimeInterval) beginningOf1980
{
    static NSTimeInterval sJanuary_6_1980 = 0;
    static dispatch_once_t  done;
    dispatch_once(&done, ^{
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSDate *myDate = [df dateFromString: @"1980-01-06"];
        
        sJanuary_6_1980 = [myDate timeIntervalSince1970];
    });
    return sJanuary_6_1980;
}

+(NSDate*) dateFrom1980:(NSTimeInterval)secondsSince1980
{
    NSTimeInterval beginningOf1980 = [self beginningOf1980];
    NSDate* result = [NSDate dateWithTimeIntervalSince1970:beginningOf1980+secondsSince1980];
    return result;
}

-(id)initWithTableHeader:(TableHeader)aHeader packetHeader:(PacketHeader)packetHeader rawData:(const unsigned char*) streamData
{
    if(nil != (self = [super initWithTableHeader:aHeader packetHeader:packetHeader rawData:streamData]))
    {
        _timeOfParsing = [[NSDate date] timeIntervalSince1970];
        unsigned char byte9 = streamData[9];
        unsigned char byte10 = streamData[10];
        unsigned char byte11 = streamData[11];
        unsigned char byte12 = streamData[12];
        _secondsSinceJanuary_6_1980 = byte9 << 24 | byte10 << 16 | byte11 << 8 | byte12;
        
        NSTimeInterval  timeIntervalSince1980 = _timeOfParsing - [SystemTimeTable beginningOf1980];
        
        _clockDifferenceInSeconds = _secondsSinceJanuary_6_1980 - timeIntervalSince1980; // should be around 5 hours in Eastern Time Zone
        unsigned char byte13 = streamData[13];
        _UTCOffset = byte13;
        
        unsigned char byte14 = streamData[14];
        _inDaylightSavingsTime = ((byte14>>7) & 1) == 1;
        _dayOfMonthForDaylightSavingsTransition = byte14 & 31;
        _hourForDaylightSavingsTransition = streamData[15];
        
    }
    return self;
}

-(NSDate*) dateFromTimeSince1980:(NSTimeInterval)secondsSince1980
{
    NSTimeInterval dateTime = secondsSince1980+self.clockDifferenceInSeconds+[SystemTimeTable beginningOf1980];
    NSDate* result = [[NSDate alloc] initWithTimeIntervalSince1970:dateTime];
    return result;
}

-(NSDate*) date
{
    NSDate* result = nil;
    NSTimeInterval january_6_1980 = [SystemTimeTable beginningOf1980];
   
    
    NSTimeInterval timeInterval = january_6_1980 + self.secondsSinceJanuary_6_1980 - self.UTCOffset;
    NSTimeInterval utcOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
    timeInterval += utcOffset;
    result = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    return result;
}

@end

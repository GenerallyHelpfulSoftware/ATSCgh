//
//  SystemTimeTable.h
//  Signal GH
//
//  Created by Glenn Howes on 1/18/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ATSCTables.h"


@interface SystemTimeTable : ATSCTable
@property(nonatomic, readonly) NSDate* date;
@property(nonatomic, readonly) unsigned char  UTCOffset;
@property(nonatomic, readonly) NSTimeInterval clockDifferenceInSeconds; // assumes this table was parsed from very fresh data.
@property(nonatomic, readonly) NSTimeInterval  timeOfParsing;
+(NSTimeInterval) beginningOf1980;
+(NSDate*) dateFrom1980:(NSTimeInterval)secondsSince1980;

-(NSDate*) dateFromTimeSince1980:(NSTimeInterval)secondsSince1980;

@end

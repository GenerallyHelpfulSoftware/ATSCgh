//
//  ScheduledShow+TV.h
//  Signal GH
//
//  Created by Glenn Howes on 2/4/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

@import CoreGraphics;

#import "ScheduledShow.h"
@class EventInformationRecord;
@class ExtendedTextTable;


@interface NSDate(DigitalTV)
-(NSDate*) dateAtNearestMinute;
+(UInt64) startTimeNearestMinute:(NSDate*)baseTime;
@end


@interface ScheduledShow (TV)
@property(nonatomic, readonly) NSString* title;
@property(nonatomic, readonly) NSString* showDescription;
@property(nonatomic, readonly) NSString* endTimeString; // only call this on the main thread
@property(nonatomic, readonly) NSString* startTimeString;
@property(nonatomic, readonly) NSString* advisoryString;

+(NSDate*) endDateFromEventRecord:(EventInformationRecord*)eventRecord withTimeOffest:(NSTimeInterval)timeOffset;
+(NSDate*) startDateFromEventRecord:(EventInformationRecord*)eventRecord withTimeOffest:(NSTimeInterval)timeOffset;

-(BOOL) bridgesDate:(NSDate*)testDate;

-(void) updateFromEventRecord:(EventInformationRecord*)eventRecord withTimeOffest:(NSTimeInterval)timeOffset;
-(void) updateFromExtendedTextTable:(ExtendedTextTable*)extendedText;

-(CGFloat)descriptionHeightForWidth:(CGFloat)width;

@end


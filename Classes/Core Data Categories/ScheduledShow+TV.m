//
//  ScheduledShow+TV.m
//  Signal GH
//
//  Created by Glenn Howes on 2/4/14.
//  Copyright (c) 2014 Generally Helpful Software. All rights reserved.
//

#import "ScheduledShow+TV.h"
#import "EventInformationTable.h"
#import "ExtendedTextTable.h"
#import "SystemTimeTable.h"
#import "LocalizedString+TV.h"
#import "ShowTitle.h"
#import "ShowDescription.h"
#import "TunerSubchannel+TV.h"
#import "TunerChannel+TV.h"
#import "LanguageString.h"
#import "ContentAdvisoryDescriptor.h"
#import "ContentAdvisory+TV.h"

@implementation NSDate(DigitalTV)


+(UInt64) startTimeNearestMinute:(NSDate*)baseTime
{
    NSTimeInterval seconds = [baseTime timeIntervalSince1970];
    seconds = rint(seconds);
    UInt64 result = seconds+30;
    result /= 60;
    result *= 60; // round to minute
    return result;
}


-(NSDate*) dateAtNearestMinute
{
    NSTimeInterval timeIntervalNearestMinute = [NSDate startTimeNearestMinute:self];
    NSDate* result = self;
    if([result timeIntervalSince1970] != timeIntervalNearestMinute)
    {
        result = [[NSDate alloc] initWithTimeIntervalSince1970:timeIntervalNearestMinute];
    }

    return result;
}
@end


@implementation ScheduledShow (TV)

-(NSString*)title
{
    NSSet* myTitles = self.titles;
    
    NSString* result = [LocalizedString bestMatchFromSet:myTitles];
    return result;
}

-(NSString*) advisoryString
{
    NSString* result = nil;
    ContentAdvisory* relevantContentAdvisory = [ContentAdvisory retrieveBestMatchFromArrayOfAdvisories:[self.contentAdvisories allObjects]];
    if(relevantContentAdvisory != nil)
    {
        result = [relevantContentAdvisory advisoryStringGivenSetOfRatings:self.subChannel.channel.ratings];
    }
    
    return result;
}

-(NSString*) showDescription
{
    NSSet* myTitles = self.descriptions;
    
    NSString* result = [LocalizedString bestMatchFromSet:myTitles];
    return result;
}


-(NSDateFormatter*) timeFormatter  // main thread only
{
    static NSDateFormatter *sResult = nil;
    
    if(sResult == nil)
    {
        sResult = [[NSDateFormatter alloc] init];
        
        [sResult setTimeStyle:NSDateFormatterShortStyle];
        [sResult setDateStyle:NSDateFormatterMediumStyle];
        
        [sResult setDoesRelativeDateFormatting:YES];
    }
    return sResult;
}

-(NSString*) startTimeString
{
    NSString* result = nil;
    NSDate* now = [NSDate date];
    NSDate* startTime = self.start_time;
    
    
    NSTimeInterval seconds = [startTime timeIntervalSinceNow];
    NSTimeInterval minutes = rint(seconds/60);
    NSInteger intMinutes = minutes;
    
    if([startTime compare:now] == NSOrderedDescending )
    {
        if(intMinutes == 0)
        {
            result = NSLocalizedString(@"Starting Now.", @"");
        }
        else if(intMinutes == 1)
        {
            result = NSLocalizedString(@"Starts in a minutes.", @"");
        }
        else if(intMinutes < 60)
        {
            NSString* formatString = NSLocalizedString(@"Starts in %d minutes.", @"");
            result = [NSString stringWithFormat:formatString, intMinutes];
        }
        else
        {
            NSString* endDateString = [[self timeFormatter] stringFromDate:startTime];
            
            NSString* formatString = NSLocalizedString(@"Starts %@.", @"");
            result = [NSString stringWithFormat:formatString, endDateString];
        }
    }
    else if([startTime compare:now] == NSOrderedAscending)
    {
        int deltaMinutes = abs((int)intMinutes);
        if(deltaMinutes == 0)
        {
            result = NSLocalizedString(@"Just Started.", @"");
        }
        else if(deltaMinutes == 1)
        {
            result = NSLocalizedString(@"Started a minute ago.", @"");
        }
        else if(deltaMinutes < 60)
        {
            NSString* formatString = NSLocalizedString(@"Started %d minutes ago.", @"");
            result = [NSString stringWithFormat:formatString, deltaMinutes];
        }
        else
        {
            NSString* endDateString = [[self timeFormatter] stringFromDate:startTime];
            
            NSString* formatString = NSLocalizedString(@"Started %@.", @"");
            result = [NSString stringWithFormat:formatString, endDateString];
        }
    }
    else
    {
        result = NSLocalizedString(@"Starting Now", @"");
    }
    
    return result;
}

-(NSString*) endTimeString
{
    NSString* result = nil;
    NSDate* now = [NSDate date];
    NSDate* startTime = self.start_time;
    NSDate* endTime = self.end_time;
    
    if([startTime compare:now] != NSOrderedDescending && [endTime compare:now] != NSOrderedAscending)
    {
        NSTimeInterval seconds = [endTime timeIntervalSinceNow];
        NSTimeInterval minutes = rint(seconds/60);
        NSInteger intMinutes = minutes;
        if(intMinutes == 1)
        {
            result = NSLocalizedString(@"Ends this minute", @"");
        }
        else if(intMinutes == 0)
        {
            if(endTime == nil)
            {
                result = @"";
            }
            else
            {
                result = NSLocalizedString(@"Ends Now", @"");
            }
        }
        else
        {
            NSString* formatString = NSLocalizedString(@"Ends in %d minutes.", @"");
            result = [NSString stringWithFormat:formatString, intMinutes];
        }
    }
    else if([endTime compare:now] == NSOrderedAscending)
    {
        NSString* endDateString = [[self timeFormatter] stringFromDate:endTime];
        
        NSString* formatString = NSLocalizedString(@"Ended %@.", @"");
        result = [NSString stringWithFormat:formatString, endDateString];
    }
    else
    {
        NSString* endDateString = [[self timeFormatter] stringFromDate:endTime];
        
        NSString* formatString = NSLocalizedString(@"Ends %@.", @"");
        result = [NSString stringWithFormat:formatString, endDateString];
    }
    
    return result;
}


+(NSDate*) startDateFromEventRecord:(EventInformationRecord*)eventRecord withTimeOffest:(NSTimeInterval)timeOffset
{
    NSTimeInterval startTime = eventRecord.start_time;
    
    NSTimeInterval dateTime = startTime+timeOffset+[SystemTimeTable beginningOf1980];
    NSDate* result = [[NSDate alloc] initWithTimeIntervalSince1970:dateTime];
    result = [result dateAtNearestMinute];
    return result;
}

+(NSDate*) endDateFromEventRecord:(EventInformationRecord*)eventRecord withTimeOffest:(NSTimeInterval)timeOffset
{
    NSDate* start_time = [ScheduledShow startDateFromEventRecord:eventRecord withTimeOffest:timeOffset];
    
    NSDate* result = [start_time dateByAddingTimeInterval:eventRecord.length_in_seconds];
    return result;
}


-(void) updateFromEventRecord:(EventInformationRecord*)eventRecord withTimeOffest:(NSTimeInterval)timeOffset;
{
    NSTimeInterval startTime = eventRecord.start_time;
    
    NSTimeInterval dateTime = startTime+timeOffset+[SystemTimeTable beginningOf1980];
    NSDate* start_time = [[NSDate alloc] initWithTimeIntervalSince1970:dateTime];
    start_time = [start_time dateAtNearestMinute];
    if(self.start_time == nil || fabs([self.start_time timeIntervalSinceDate:start_time]) > 120)
    {
           self.start_time = start_time;
    }
    NSDate* end_time = [start_time dateByAddingTimeInterval:eventRecord.length_in_seconds];
    self.end_time = end_time;
    self.event_id = [NSNumber numberWithInteger:eventRecord.event_id];
    
    NSEntityDescription *showTitleEntity = [NSEntityDescription entityForName:@"ShowTitle" inManagedObjectContext:[self managedObjectContext]];
    
    for(LanguageString* aLanguageString in eventRecord.titles)
    {
        BOOL foundIt = NO;
        for(ShowTitle* aTitle in self.titles)
        {
            if([aTitle.locale isEqualToString:aLanguageString.languageCode])
            {
                foundIt = YES;
                aTitle.text = aLanguageString.string;
                break;
            }
        }
        if(!foundIt)
        {
            ShowTitle* newTitle = [[ShowTitle alloc] initWithEntity:showTitleEntity insertIntoManagedObjectContext:self.managedObjectContext];
            newTitle.locale = aLanguageString.languageCode;
            newTitle.text = aLanguageString.string;
            newTitle.show = self;
            [self addTitlesObject:newTitle];
        }
    }
    if(self.contentAdvisories.count == 0)
    {
        for(ATSCTable* aTable in eventRecord.descriptors)
        {
            if([aTable isKindOfClass:[ContentAdvisoryDescriptor class]])
            {
                ContentAdvisoryDescriptor* contentAdvisoryTable = (ContentAdvisoryDescriptor*)aTable;
                [ContentAdvisory extractAdvisoriesFromDescriptors:contentAdvisoryTable intoShow:self];
            }
        }
    }
}

-(void) updateFromExtendedTextTable:(ExtendedTextTable*)extendedText
{
    NSEntityDescription *showDescriptionEntity = [NSEntityDescription entityForName:@"ShowDescription" inManagedObjectContext:[self managedObjectContext]];
    for(LanguageString* aLanguageString in extendedText.strings)
    {
        BOOL foundIt = NO;
        for(ShowDescription* aDescription in self.descriptions)
        {
            if([aDescription.locale isEqualToString:aLanguageString.languageCode] && aLanguageString.string.length)
            {
                foundIt = YES;
                aDescription.text = aLanguageString.string;
                break;
            }
        }
        if(!foundIt)
        {
            ShowDescription* newDescription = [[ShowDescription alloc] initWithEntity:showDescriptionEntity insertIntoManagedObjectContext:self.managedObjectContext];
            newDescription.locale = aLanguageString.languageCode;
            newDescription.text = aLanguageString.string;
            newDescription.show = self;
            [self addDescriptionsObject:newDescription];
        }
    }
}


-(CGFloat)descriptionHeightForWidth:(CGFloat)width
{
    CGFloat result = 0.0;
    NSString* description = self.showDescription;
    if(description.length)
    {
        NSStringDrawingContext* drawingContext = [[NSStringDrawingContext alloc] init];
        UIFontDescriptor* fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleCaption1];
        CGSize fitToSize = CGSizeMake(width, 480);
        CGRect boundingRect = [description boundingRectWithSize:fitToSize options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:fontDescriptor.fontAttributes context:drawingContext];
        result = boundingRect.size.height;
    }
    return result;
}

@end


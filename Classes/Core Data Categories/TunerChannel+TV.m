//
//  TunerChannel+TV.m
//  Signal GH
//
//  Created by Glenn Howes on 12/28/13.
//  Copyright (c) 2013 Generally Helpful Software. All rights reserved.
//

#import "TunerChannel+TV.h"
#import "ATSCTables.h"
#import "RatingRegionTable.h"
#import "LanguageString.h"
#import "EventInformationTable.h"
#import "ExtendedTextTable.h"
#import "AudioStreamDescriptor.h"
#import "Rating+TV.h"
#import "Tower.h"
#import "TVBroadcaster.h"
#import "TunerSubchannel+TV.h"
#import "HDHomeRunWrapper.h"
#import "StringConstants.h"

@implementation TunerChannel (TV)

-(NSString*) trimmedCallsign
{
    NSString* result = self.callsign;
    if(result.length)
    {
        NSRange rangeOfDash = [result rangeOfString:@"-"];
        if(rangeOfDash.location != NSNotFound && rangeOfDash.location > 0)
        {
            result = [result substringToIndex:rangeOfDash.location];
        }
    }
    
    return result;
}

-(Tower*)tower
{
    Tower* result = nil;
    NSString* callSign = self.callsign;
    if(callSign.length)
    {
        if([callSign hasSuffix:@"-HD"])
        {
            callSign = [callSign stringByReplacingOccurrencesOfString:@"-HD" withString:@"-TV"];
        }
        else if([callSign hasSuffix:@"-SD"])
        {
            callSign = [callSign stringByReplacingOccurrencesOfString:@"-SD" withString:@"-TV"];
        }
        else if(![callSign hasSuffix:@"-TV"])
        {
            NSRange rangeOfDash = [callSign rangeOfString:@"-"];
            if(rangeOfDash.location == NSNotFound)
            {
                callSign = [callSign stringByAppendingString:@"-TV"];
            }
        }
        result = [[BroadcasterModel sharedModel] towerWithCallSign:callSign];
    }
    return result;
}

-(Network*) network
{
    Network* result = nil;
    for(TunerSubchannel* subChannel in self.subchannels)
    {
        if(subChannel.virtualMinorChannelNumber.integerValue == 1)
        {
            result = subChannel.network;
            break;
        }
    }
    
    if(result == nil)
    {
        Tower* myTower = self.tower;
        TVBroadcaster* myBroadcaster = myTower.broadcaster;
        NSSet* networks = myBroadcaster.networks;
        result = networks.anyObject;
        
    }
    return result;
}


-(void) extractATSCTables:(NSDictionary*)newATSCTables
{
    for(ATSCTable* aTable in newATSCTables.allValues)
    {
        if([aTable isKindOfClass:[RatingRegionTable class]])
        {
            RatingRegionTable* ratingTable = (RatingRegionTable*)aTable;
            if(ratingTable.rating_dimensions.count != self.ratings.count)
            {
                [Rating extractRatingsFromRatingTable:ratingTable forChannel:self];
            }
            else if(self.ratings.count)
            {
                [Rating updateRatings:self.ratings fromRatingTable:ratingTable];
            }
        }
    }
}

-(void) configureFromStandardDescription:(NSDictionary *)description
{
    self.frequency = [description valueForKey:kTunerFrequencyTag];
    self.standardsTable = [description valueForKey:kChannelMapStandardTag];
    self.number = [description valueForKey:kRealChannelTag];
}

@end

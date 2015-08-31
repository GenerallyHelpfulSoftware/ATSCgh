//
//  StringConstants.m
//  Signal GH
//
//  Created by Glenn Howes on 8/30/15.
//  Copyright © 2015 Generally Helpful Software. All rights reserved.
//

#import "StringConstants.h"

NSString* const kTunerFrequencyTag		= @"Frequency"; // NSNUMBER (integer)
NSString* const kRealChannelTag			= @"Real Channel"; // NSNUMBER (integer)
NSString* const kShowChannelInList	= @"Show Channel in List"; // NSNumber (BOOL)
NSString* const kChannelMapStandardTag = @"Channel Standard";

NSString* const kProgramsArrayTag		= @"Subchannel Records"; // NSArray of NSDictionaries
NSString* const     kProgramNameTag		= @"Subchannel Name";	// NSString
NSString* const     kProgramVirtualMajorChannelTag	= @"Subchannel Major Virtual Channel"; // NSNumber (integer) like the 25 in 25.1
NSString* const     kProgramVirtualMinorChannelTag	= @"Subchannel Minor Virtual Channel"; // NSNumber (integer) like the 1 in 25.1



NSString* const kAmericanChannelsTag	= @"us-bcast";
NSString* const kEuropeanChannelsTag	= @"eu-bcast";
NSString* const kTaiwanChannelsTag	= @"tw-bcast";
NSString* const kAustralianChannelsTag= @"au-bcast";
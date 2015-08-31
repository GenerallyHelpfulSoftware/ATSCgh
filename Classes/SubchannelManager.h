//
//  SubchannelManager.h
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
//  Created by Glenn Howes on 12/28/13.
//  Copyright (c) 2013 Generally Helpful Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TunerChannel+TV.h"
#import "TunerSubchannel+TV.h"

@class MasterGuideTable;
@class TerrestrialVirtualChannelTable;


typedef void (^channel_retrieval_t)(TunerChannel* tunerChannel, NSError* error);
typedef void (^subchannel_retrieval_t)(TunerSubchannel* tunerChannel, NSError* error);

typedef void(^channelIDs_retrieval_t)(NSArray* favoriteChannels, NSError*error);

typedef void(^scheduledShow_retrieval_t)(ScheduledShow* aShow, NSError* error);
typedef void(^cleanOldShows_t)();

@interface SubchannelManager : NSObject
@property(nonatomic, readonly) NSManagedObjectModel*			managedObjectModel;
@property (nonatomic, readonly) NSManagedObjectContext*			managedObjectContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator*	persistentStoreCoordinator;
@property (nonatomic, assign) BOOL                              needToReinit;


+(SubchannelManager*) sharedModel;
-(SubchannelManager*)newChildModel; // for temporary generation with possible revert
-(SubchannelManager*)newBackgroundChildModel;

-(void) retrieveChannelWithID:(NSManagedObjectID*) objectID intoCallback:(channel_retrieval_t)callback;
-(void) retrieveSubChannelWithID:(NSManagedObjectID*) objectID intoCallback:(subchannel_retrieval_t)callback;
-(void) retrieveScheduledShowWithID:(NSManagedObjectID*)objectID intoCallback:(scheduledShow_retrieval_t)callback;
-(void) syncRetrieveScheduledShowWithID:(NSManagedObjectID*)objectID intoCallback:(scheduledShow_retrieval_t)callback;
-(void) retrieveChannelAtFrequency:(NSNumber*)frequency inStandard:(NSString*)standards intoCallback:(channel_retrieval_t)callback;

-(void) retrieveFavoriteChannelsIDs:(channelIDs_retrieval_t)callback;

-(void) saveOutTables:(NSDictionary*)extractedTables definedByMasterGuideTable:(MasterGuideTable*)masterTable andTerrestrialChannels:(TerrestrialVirtualChannelTable*)terrestrialTable forTunerChannelWithID:(NSManagedObjectID*)tunerChannelID;

-(void) addChannelDescription:(NSDictionary*)channelDescription withStandard:(NSString*)standard deleteEmptyChannels:(BOOL)deleteEmpty withCallback:(channel_retrieval_t)callback;


-(NSFetchedResultsController*) newFavoriteFetchResultsControllerForFromStandard:(NSString*)standardString;
-(NSFetchedResultsController*) newSubChannelsFetchResultsControllerForFromStandard:(NSString*)standardString;
-(NSFetchedResultsController*) newSheduledShowsSortTimeResultsController;
-(NSFetchedResultsController*) newSheduledShowsSortChannelsResultsController;

-(NSFetchedResultsController*) newChannelsFetchResultsControllerForStandards:(NSArray*)standards;
-(NSFetchedResultsController*) newSeenChannelsFetchResultsControllerForStandards:(NSArray*)standards;
-(NSFetchedResultsController*) newFavoriteChannelsFetchResultsControllerForStandards:(NSArray*)standards;
-(NSFetchedResultsController*) newFavoriteOrActiveChannelsFetchResultsController;

-(NSFetchedResultsController*) newFavoriteChannelsFetchResultsController;

-(NSArray*)activeChannels;
-(void) makeSetActive:(NSSet*) setOfTunerChannels; //
-(void) cleanOldShows:(cleanOldShows_t)callback;
-(void) saveOut;
@end

extern NSString* const kUpdatedScheduledShows;
extern NSString* const kFavoriteSubchannelsChanged;
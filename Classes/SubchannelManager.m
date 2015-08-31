//
//  SubchannelManager.m
//  Signal GH
//
//  Created by Glenn Howes on 12/28/13.
//  Copyright (c) 2013 Generally Helpful Software. All rights reserved.
//

#import "SubchannelManager.h"
#import "MasterGuideTable.h"
#import "TerrestrialVirtualChannelTable.h"
#import "EventInformationTable.h"
#import "ExtendedTextTable.h"
#import "ScheduledShow.h"
#import "ChannelListWrapper.h"
#import "StringConstants.h"

NSString* const kUpdatedScheduledShows = @"kUpdatedScheduledShows";
NSString* const kFavoriteSubchannelsChanged = @"kFavoriteSubchannelsChanged";

@interface SubchannelManager()

@property(nonatomic, strong) NSManagedObjectContext* backgroundObjectContext;

@property(nonatomic, strong) NSManagedObjectModel*			managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext*			managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator*	persistentStoreCoordinator;
@end

@implementation SubchannelManager
+(SubchannelManager*) sharedModel
{
    static SubchannelManager* sResult = nil;
    static dispatch_once_t  done;
    dispatch_once(&done, ^{
        sResult = [SubchannelManager new];
    });
    
    return sResult;
}


-(SubchannelManager*)newChildModel
{
    SubchannelManager*  result = [[self class] new];

    result.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [result.managedObjectContext setParentContext:self.managedObjectContext];
    
    return result;
}

-(SubchannelManager*)newBackgroundChildModel
{
    SubchannelManager*  result = [[self class] new];
    
    result.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [result.managedObjectContext setParentContext:self.managedObjectContext];
    
    return result;
}

- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(void) saveOut
{
    if (_managedObjectContext != nil)
	{
        __block UIBackgroundTaskIdentifier backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
        [self.managedObjectContext performBlock:^{
            NSError *error = nil;
            if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error])
            {
                // Handle error
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskID];
        }];
    }

}

-(void) applicationWillBackgroundNotification:(NSNotification*) notification
{
    [self saveOut];
}

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
  //  [self saveOut];
}

-(void) saveOutTables:(NSDictionary*)extractedTables definedByMasterGuideTable:(MasterGuideTable*)masterTable andTerrestrialChannels:(TerrestrialVirtualChannelTable*)terrestrialTable forTunerChannelWithID:(NSManagedObjectID*)tunerChannelID
{
    [self.managedObjectContext performBlock:^{
        NSError* error = nil;
        TunerChannel* myChannel = (TunerChannel*)[self.managedObjectContext existingObjectWithID:tunerChannelID error:&error];
        if(error == nil)
        {
            [myChannel extractATSCTables:extractedTables];
            
            for(TunerSubchannel* aSubChannel in myChannel.subchannels)
            {
                if(aSubChannel.favorite.boolValue)
                {
                    for(TerrestrialVirtualChannel* aVirtualChannel in terrestrialTable.channels)
                    {
                        if(aVirtualChannel.major_channel_number == aSubChannel.virtualMajorChannelNumber.intValue
                           && aVirtualChannel.minor_channel_number == aSubChannel.virtualMinorChannelNumber.intValue)
                        { // this terrestrial channel corresponds to my tuner channel
                            [aSubChannel extractTables:extractedTables withVirtualChannel:aVirtualChannel];
                        }
                    }
                }
            }
            
            [self.managedObjectContext save:&error];
        }
        if(error != nil)
        {
            NSLog(@"Error saving out scheduled show data:%@", error);
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdatedScheduledShows object:nil];
        }
    }];
}

-(void) retrieveFavoriteChannelsIDs:(channelIDs_retrieval_t)callback
{
    [self.managedObjectContext performBlock:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TunerSubchannel" inManagedObjectContext:[self managedObjectContext]];
        [request setEntity:entity];
        
        NSPredicate*	thePredicate = [NSPredicate predicateWithFormat:@"favorite != NO"];
        [request setPredicate:thePredicate];
        
        
        NSError *error=nil;
        NSArray* subChannels = [self.managedObjectContext executeFetchRequest:request error:&error];
        if(subChannels.count && error == nil)
        {
            NSMutableSet* mutableResult = [[NSMutableSet alloc] initWithCapacity:subChannels.count*4];
            for(TunerSubchannel* aSubChannel in subChannels)
            {
                [mutableResult addObject:aSubChannel.channel.objectID];
            }
            callback([mutableResult allObjects], nil);
        }
        else
        {
            callback(nil, error);
        }
    }];
}

-(NSFetchRequest*)newSubchannelRequestWithStandard:(NSString*)standardString
{
    NSFetchRequest *result = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"TunerSubchannel" inManagedObjectContext:[self managedObjectContext]];
	[result setEntity:entity];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"virtualMajorChannelNumber" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"virtualMinorChannelNumber" ascending:YES];
    
    NSArray* sortDescriptors = @[sortDescriptor1,sortDescriptor2];
    
    result.sortDescriptors =sortDescriptors;
    return result;

}

-(NSPredicate*) orPredicatesForStandards:(NSArray*)standards
{
    NSMutableArray* standardsPredicates = [[NSMutableArray alloc] initWithCapacity:standards.count];
    for(NSString* aStandard in standards)
    {
        NSPredicate*	thePredicate = [NSPredicate predicateWithFormat:@"standardsTable == %@", aStandard];
        [standardsPredicates addObject:thePredicate];
    }
    
    NSPredicate* result = [NSCompoundPredicate orPredicateWithSubpredicates:standardsPredicates];
    return result;
}

-(void) populateTunerChannelsForStandards:(NSArray*)standards
{
    [self.managedObjectContext performBlockAndWait:^{
        
        NSError* error = nil;
        NSEntityDescription *tunerChannelEntity = [NSEntityDescription entityForName:@"TunerChannel" inManagedObjectContext:[self managedObjectContext]];
        
        for(NSString* aStandard in standards)
        {
            NSPredicate*	thePredicate = [NSPredicate predicateWithFormat:@"standardsTable == %@", aStandard];
            NSFetchRequest *fetchRequest = [NSFetchRequest new];
            [fetchRequest setEntity:tunerChannelEntity];
            [fetchRequest setPredicate:thePredicate];
            
            if([self.managedObjectContext countForFetchRequest:fetchRequest error:&error] == 0) // need to pre-populate the list of channels
            {
                if(error != nil)
                {
                    NSLog(@"Error accessing subchannel database: %@", error.localizedDescription);
                }
                else
                {
                    ChannelListWrapper* listWrapper = [ChannelListWrapper listWrapperForStandard:aStandard];
                    NSArray* standardChannels = listWrapper.allChannels;
                    for(NSDictionary* aDescription in standardChannels)
                    {
                        TunerChannel* aChannel = (TunerChannel*)[[TunerChannel alloc] initWithEntity:tunerChannelEntity insertIntoManagedObjectContext:self.managedObjectContext];
                        aChannel.standardsTable = aStandard;
                        [aChannel configureFromStandardDescription:aDescription];
                    }
                    
                    
                }
            }
        }
        if(self.managedObjectContext.hasChanges)
        {
            [self.managedObjectContext save:&error];
            
            if(error != nil)
            {
                NSLog(@"Error creating channels for database: %@", error.localizedDescription);
            }
        }
        
    }];
}

-(NSFetchedResultsController*) newSeenChannelsFetchResultsControllerForStandards:(NSArray*)standards
{
    [self populateTunerChannelsForStandards:standards];
    
    
    NSFetchRequest* allChannelsRequest = [NSFetchRequest new];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TunerChannel" inManagedObjectContext:[self managedObjectContext]];
    [allChannelsRequest setEntity:entity];
    NSPredicate* standardsPredicate = [self orPredicatesForStandards:standards];
    NSPredicate* seenPredicate = [NSPredicate predicateWithFormat:@"seen == 1"];
    NSPredicate* thePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[standardsPredicate, seenPredicate]];
    [allChannelsRequest setPredicate:thePredicate];
    
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"standardsTable" ascending:YES];
    [allChannelsRequest setSortDescriptors:@[sortDescriptor2, sortDescriptor1]];
    
    NSFetchedResultsController *result = [[NSFetchedResultsController alloc] initWithFetchRequest:allChannelsRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"standardsTable" cacheName:nil];
    
    return result;
}

-(NSFetchedResultsController*) newFavoriteChannelsFetchResultsControllerForStandards:(NSArray*)standards
{
    [self populateTunerChannelsForStandards:standards];
    NSFetchRequest* allChannelsRequest = [NSFetchRequest new];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TunerChannel" inManagedObjectContext:[self managedObjectContext]];
    [allChannelsRequest setEntity:entity];
    NSPredicate* standardsPredicate = [self orPredicatesForStandards:standards];
    NSPredicate* seenPredicate = [NSPredicate predicateWithFormat:@"favorite == YES"];
    NSPredicate* thePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[standardsPredicate, seenPredicate]];
    [allChannelsRequest setPredicate:thePredicate];
    
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"standardsTable" ascending:YES];
    [allChannelsRequest setSortDescriptors:@[sortDescriptor2, sortDescriptor1]];
    
    NSFetchedResultsController *result = [[NSFetchedResultsController alloc] initWithFetchRequest:allChannelsRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"standardsTable" cacheName:nil];
    
    return result;
}

-(NSFetchedResultsController*) newFavoriteChannelsFetchResultsController
{
    NSFetchRequest* allChannelsRequest = [NSFetchRequest new];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TunerChannel" inManagedObjectContext:[self managedObjectContext]];
    [allChannelsRequest setEntity:entity];
    NSPredicate* favouritePredicate = [NSPredicate predicateWithFormat:@"favorite == 1"];
    [allChannelsRequest setPredicate:favouritePredicate];
    
    
    NSSortDescriptor *sortDescriptor0 = [[NSSortDescriptor alloc] initWithKey:@"standardsTable" ascending:YES];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"virtualMajorChannelNumber" ascending:YES];
    [allChannelsRequest setSortDescriptors:@[sortDescriptor0, sortDescriptor2, sortDescriptor1]];
    
    NSFetchedResultsController *result = [[NSFetchedResultsController alloc] initWithFetchRequest:allChannelsRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"standardsTable" cacheName:nil];
    
    return result;
}

-(NSFetchedResultsController*) newFavoriteOrActiveChannelsFetchResultsController
{
    NSFetchRequest* allChannelsRequest = [NSFetchRequest new];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TunerChannel" inManagedObjectContext:[self managedObjectContext]];
    [allChannelsRequest setEntity:entity];
    NSPredicate* favouritePredicate = [NSPredicate predicateWithFormat:@"favorite == 1 OR active == 1"];
    [allChannelsRequest setPredicate:favouritePredicate];
    
    
    NSSortDescriptor *sortDescriptor0 = [[NSSortDescriptor alloc] initWithKey:@"standardsTable" ascending:YES];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"virtualMajorChannelNumber" ascending:YES];
    [allChannelsRequest setSortDescriptors:@[sortDescriptor0, sortDescriptor2, sortDescriptor1]];
    
    NSFetchedResultsController *result = [[NSFetchedResultsController alloc] initWithFetchRequest:allChannelsRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"standardsTable" cacheName:nil];
    
    return result;
}

-(void) makeSetActive:(NSSet *)setOfTunerChannels
{
    
    NSArray* nominallyActiveChannels = [self activeChannels];
    
    [self.managedObjectContext performBlockAndWait:^{
        
        for(TunerChannel* aChannel in nominallyActiveChannels)
        {
            if(![setOfTunerChannels containsObject:aChannel])
            {
                aChannel.active = @NO;
            }
        }
    }];
}

-(NSArray*)activeChannels
{
    __block NSArray* result = nil;
    NSFetchRequest* activeChannels = [NSFetchRequest new];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TunerChannel" inManagedObjectContext:[self managedObjectContext]];
    [activeChannels setEntity:entity];
    NSPredicate* favouritePredicate = [NSPredicate predicateWithFormat:@"active == 1"];
    [activeChannels setPredicate:favouritePredicate];
    
    [self.managedObjectContext performBlockAndWait:^{
        NSError* error = nil;
        
        result = [self.managedObjectContext executeFetchRequest:activeChannels error:&error];
    }];
    return result;
}

-(void) retrieveChannelAtFrequency:(NSNumber*)frequency inStandard:(NSString*)standard intoCallback:(channel_retrieval_t)callback
{
    
    NSFetchRequest* fetchRequest = [NSFetchRequest new];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TunerChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    
    NSPredicate* thePredicate = [NSPredicate predicateWithFormat:@"standardsTable == %@ AND frequency == %@", standard, frequency];
    [fetchRequest setPredicate:thePredicate];
    
    fetchRequest.fetchBatchSize = 1;
    
    [self.managedObjectContext performBlockAndWait:^{
        NSError* error = nil;
        NSArray* shouldBeOne = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if(shouldBeOne.count)
        {
            callback(shouldBeOne.firstObject, nil);
        }
        else
        {
            callback(nil, error);
        }
        
    }];
}

-(NSFetchedResultsController*) newChannelsFetchResultsControllerForStandards:(NSArray*)standards
{
    [self populateTunerChannelsForStandards:standards];
    
    NSFetchRequest* allChannelsRequest = [NSFetchRequest new];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TunerChannel" inManagedObjectContext:[self managedObjectContext]];
    [allChannelsRequest setEntity:entity];
    NSPredicate* thePredicate = [self orPredicatesForStandards:standards];
    [allChannelsRequest setPredicate:thePredicate];
    
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"standardsTable" ascending:YES];
    [allChannelsRequest setSortDescriptors:@[sortDescriptor2, sortDescriptor1]];
    
    NSFetchedResultsController *result = [[NSFetchedResultsController alloc] initWithFetchRequest:allChannelsRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"standardsTable" cacheName:nil];
    
    return result;
}

-(void) retrieveChannelWithID:(NSManagedObjectID*) objectID intoCallback:(channel_retrieval_t)callback
{
    [self.managedObjectContext performBlock:^{
        TunerChannel* result = nil;
        NSError* error = nil;
        NSManagedObject * objectResult = [self.managedObjectContext existingObjectWithID:objectID error:&error];
        NSAssert(objectResult == nil || [objectResult isKindOfClass:[TunerChannel class]], @"Expected a TunerChannel");
        result = (TunerChannel*)objectResult;
        
        callback(result, error);
    }];
}


-(void) retrieveSubChannelWithID:(NSManagedObjectID*) objectID intoCallback:(subchannel_retrieval_t)callback
{
    [self.managedObjectContext performBlock:^{
        TunerSubchannel* result = nil;
        NSError* error = nil;
        NSManagedObject * objectResult = [self.managedObjectContext existingObjectWithID:objectID error:&error];
        NSAssert(objectResult == nil || [objectResult isKindOfClass:[TunerSubchannel class]], @"Expected a TunerSubchannel");
        result = (TunerSubchannel*)objectResult;
        
        callback(result, error);
    }];

}


-(void) retrieveScheduledShowWithID:(NSManagedObjectID*)objectID intoCallback:(scheduledShow_retrieval_t)callback
{
    [self.managedObjectContext performBlock:^{
        [self syncRetrieveScheduledShowWithID:objectID intoCallback:callback];
    }];
}

-(void) syncRetrieveScheduledShowWithID:(NSManagedObjectID*)objectID intoCallback:(scheduledShow_retrieval_t)callback
{
    __block ScheduledShow* result = nil;
    __block NSError* error = nil;
    [self.managedObjectContext performBlockAndWait:^{
        
        NSManagedObject * objectResult = [self.managedObjectContext existingObjectWithID:objectID error:&error];
        NSAssert(objectResult == nil || [objectResult isKindOfClass:[ScheduledShow class]], @"Expected a TunerSubchannel");
        result = (ScheduledShow*)objectResult;
    }];
    
    callback(result, error);
}

-(NSFetchRequest*) newFavoriteRequestWithStandard:(NSString*)standardString
{
    NSFetchRequest *result = [self newSubchannelRequestWithStandard:standardString];
	NSPredicate*	thePredicate = [NSPredicate predicateWithFormat:@"favorite == YES AND channel.standardsTable == %@", standardString];
	[result setPredicate:thePredicate];
    
    return result;
}

-(NSFetchedResultsController*) newFavoriteFetchResultsControllerForFromStandard:(NSString*)standardString
{
    NSFetchRequest* favoriteRequest = [self newFavoriteRequestWithStandard:standardString];
    NSFetchedResultsController *result = [[NSFetchedResultsController alloc] initWithFetchRequest:favoriteRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"FavoriteSubchannels"];
    return result;
}

-(NSFetchedResultsController*) newSubChannelsFetchResultsControllerForFromStandard:(NSString*)standardString
{
    NSFetchRequest* subchannelsRequest = [self newSubchannelRequestWithStandard:standardString];
    
	NSPredicate*	thePredicate = [NSPredicate predicateWithFormat:@"channel.standardsTable == %@", standardString];
	[subchannelsRequest setPredicate:thePredicate];
    NSFetchedResultsController *result = [[NSFetchedResultsController alloc] initWithFetchRequest:subchannelsRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Subchannels"];
    return result;
}

-(NSFetchedResultsController*) newSheduledShowsSortChannelsResultsController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ScheduledShow" inManagedObjectContext:[self managedObjectContext]];
	[fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"subChannel.virtualMajorChannelNumber" ascending:YES];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"subChannel.virtualMinorChannelNumber" ascending:YES];
    NSSortDescriptor *sortDescriptor4 = [[NSSortDescriptor alloc] initWithKey:@"start_time" ascending:YES];
    
    NSArray* sortDescriptors = @[sortDescriptor2,sortDescriptor3, sortDescriptor4];
    
    fetchRequest.sortDescriptors =sortDescriptors;
    
    
	NSPredicate*	thePredicate = [NSPredicate predicateWithFormat:@"subChannel != nil && subChannel.favorite == YES"];
	[fetchRequest setPredicate:thePredicate];
    
    NSFetchedResultsController *result = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"subChannel.userVisibleName" cacheName:nil];
    return result;
}

-(NSFetchedResultsController*) newSheduledShowsSortTimeResultsController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ScheduledShow" inManagedObjectContext:[self managedObjectContext]];
	[fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"start_time" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"subChannel.virtualMajorChannelNumber" ascending:YES];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"subChannel.virtualMinorChannelNumber" ascending:YES];
    
    NSArray* sortDescriptors = @[sortDescriptor1,sortDescriptor2, sortDescriptor3];
    
    fetchRequest.sortDescriptors =sortDescriptors;
    
    
	NSPredicate*	thePredicate = [NSPredicate predicateWithFormat:@"subChannel != nil && subChannel.favorite == YES"];
	[fetchRequest setPredicate:thePredicate];

    NSFetchedResultsController *result = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"start_time" cacheName:nil];
    return result;
}

-(void) cleanOldShows:(cleanOldShows_t)callback
{
    [self.managedObjectContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest new];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ScheduledShow" inManagedObjectContext:[self managedObjectContext]];
        NSPredicate* oldPredicate = [NSPredicate predicateWithFormat:@"end_time < %@", [NSDate date]];
        
        [fetchRequest setEntity:entity];
        fetchRequest.predicate = oldPredicate;
        
        NSArray *oldShows = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        
        
        for (NSManagedObject* anObject in oldShows) {
            [self.managedObjectContext deleteObject:anObject];
        }
        
        NSError* error = nil;
      //  [self.managedObjectContext save:&error];
        if(error != nil)
        {
            NSLog(@"Error adding to context: %@", error);
        }
        callback();

    }];
}

-(void) addChannelDescription:(NSDictionary*)channelDescription  withStandard:(NSString*)standardString deleteEmptyChannels:(BOOL) deleteEmpty withCallback:(channel_retrieval_t)callback
{
    [self.managedObjectContext performBlock:^{
        NSArray* arrayOfPrograms = [channelDescription objectForKey:kProgramsArrayTag];
        NSString* callsign = [channelDescription objectForKey:kProgramNameTag];
        NSNumber* realChannel = [channelDescription objectForKey:kRealChannelTag];
        NSNumber* virtualMajor = [channelDescription objectForKey:kProgramVirtualMajorChannelTag];
        
        NSFetchRequest* channelFetcher = [NSFetchRequest new];
        NSEntityDescription *tunerChannelEntity = [NSEntityDescription entityForName:@"TunerChannel" inManagedObjectContext:[self managedObjectContext]];
        [channelFetcher setEntity:tunerChannelEntity];
        
        
        NSPredicate*	thePredicate = [NSPredicate predicateWithFormat:@"standardsTable == %@ AND number == %@", standardString, realChannel]; // might be replaced
        [channelFetcher setPredicate:thePredicate];
        
        NSError* error = nil;
        TunerChannel* theChannel = nil;
        NSArray* oneChannel = [self.managedObjectContext executeFetchRequest:channelFetcher error:&error];
        if(error != nil)
        {
            NSLog(@"Error reading channel: %@", error);
        }
        else if(oneChannel.count == 0)
        {
            if(arrayOfPrograms.count)
            {
                theChannel = (TunerChannel*)[[TunerChannel alloc] initWithEntity:tunerChannelEntity insertIntoManagedObjectContext:self.managedObjectContext];
                theChannel.number = realChannel;
                theChannel.standardsTable = standardString;
                theChannel.frequency = channelDescription[kTunerFrequencyTag];
                [self.managedObjectContext processPendingChanges];
            }
        }
        else
        {
            theChannel = oneChannel.lastObject;
        }
        
        if(arrayOfPrograms.count)
        {
        
            theChannel.virtualMajorChannelNumber = virtualMajor;
            theChannel.callsign = callsign;
            
            NSMutableDictionary* subChannelsToAdd = [[NSMutableDictionary alloc] init];
            NSSet* channelsStartChannels = theChannel.subchannels;
            
            
            for(NSDictionary* aSubChannelDescription in arrayOfPrograms)
            {
                [subChannelsToAdd setObject:aSubChannelDescription forKey:aSubChannelDescription[kProgramVirtualMinorChannelTag]];
            }
            
            for(TunerSubchannel* aTunerSubchannel in channelsStartChannels)
            {
                NSNumber* virtualNumber = aTunerSubchannel.virtualMinorChannelNumber;
                NSDictionary* aSubChannelDescription = [subChannelsToAdd objectForKey:virtualNumber];
                if(aSubChannelDescription)
                {
                    aTunerSubchannel.virtualMajorChannelNumber = aSubChannelDescription[kProgramVirtualMajorChannelTag];
                    aTunerSubchannel.virtualMinorChannelNumber = aSubChannelDescription[kProgramVirtualMinorChannelTag];
                    
                    aTunerSubchannel.programName = aSubChannelDescription[kProgramNameTag];
                    [subChannelsToAdd removeObjectForKey:virtualNumber];
                }
                else
                {
                    [theChannel removeSubchannelsObject:aTunerSubchannel];
                }
            }
            
            for(NSDictionary* aSubChannelDescription in subChannelsToAdd.allValues)
            {
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"TunerSubchannel" inManagedObjectContext:[self managedObjectContext]];
                TunerSubchannel* aTunerSubchannel = (TunerSubchannel*)[[TunerSubchannel alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
                
                aTunerSubchannel.virtualMajorChannelNumber = aSubChannelDescription[kProgramVirtualMajorChannelTag];
                aTunerSubchannel.virtualMinorChannelNumber = aSubChannelDescription[kProgramVirtualMinorChannelTag];
                aTunerSubchannel.programName = aSubChannelDescription[kProgramNameTag];
                aTunerSubchannel.channel = theChannel;
                [theChannel addSubchannelsObject:aTunerSubchannel];
                
            }
            [self.managedObjectContext save:&error];
        }
        else if(theChannel != nil)
        {
            if(deleteEmpty)
            {
                [self.managedObjectContext deleteObject:theChannel];
                [self.managedObjectContext processPendingChanges];
                theChannel = nil;
            }
            else
            {
                
            }
        }
        callback(theChannel, error);
    }];
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext
{
    if (_managedObjectContext != nil)
	{
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
	{
		[[NSNotificationCenter defaultCenter]
		 addObserver:self selector:@selector(applicationWillTerminateNotification:)
		 name:UIApplicationWillTerminateNotification object:nil];
		
		[[NSNotificationCenter defaultCenter]
		 addObserver:self selector:@selector(applicationWillBackgroundNotification:)
		 name:UIApplicationWillResignActiveNotification object:nil];
		
		
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
	{
        return _managedObjectModel;
    }
    
    NSBundle* myBundle = [NSBundle bundleForClass:[self class]];
    NSURL*  myModelURL = [myBundle URLForResource:@"TunerChannel" withExtension:@"momd"]; // this may have to use a momd if the model is versioned
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:myModelURL];
    return _managedObjectModel;
}

-(NSString*)baseDatabaseFileName
{
    NSString* result = @"Subchannels";
    
    return result;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
	{
        return _persistentStoreCoordinator;
    }
	NSString*	fileName = [NSString stringWithFormat:@"%@.sqlite", [self baseDatabaseFileName]];
    NSError* error = nil;
    NSFileManager* localFileManager = [NSFileManager new];
    [localFileManager createDirectoryAtURL:[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] withIntermediateDirectories:YES attributes:nil error:nil];
    
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:fileName];
    
	NSURL *storeURL = [NSURL fileURLWithPath:storePath];
	
	NSDictionary *option = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							[NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	if (![_persistentStoreCoordinator
		  addPersistentStoreWithType:NSSQLiteStoreType
		  configuration:nil
		  URL:storeURL
		  options:option error:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        self.needToReinit = YES;
        _persistentStoreCoordinator = nil;
        [localFileManager removeItemAtPath:storePath error:nil];
	}
    return _persistentStoreCoordinator;
}
@end

//
//  TunerSubchannel+CoreDataProperties.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/7/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreData


extension TunerSubchannel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TunerSubchannel> {
        return NSFetchRequest<TunerSubchannel>(entityName: "TunerSubchannel")
    }

    @NSManaged public var favorite: NSNumber?
    @NSManaged public var programName: String?
    @NSManaged public var userVisibleName: String?
    @NSManaged public var virtualMajorChannelNumber: NSNumber?
    @NSManaged public var virtualMinorChannelNumber: NSNumber?
    @NSManaged public var channel: TunerChannel?
    @NSManaged public var shows: NSSet?

}

// MARK: Generated accessors for shows
extension TunerSubchannel {

    @objc(addShowsObject:)
    @NSManaged public func addToShows(_ value: ScheduledShow)

    @objc(removeShowsObject:)
    @NSManaged public func removeFromShows(_ value: ScheduledShow)

    @objc(addShows:)
    @NSManaged public func addToShows(_ values: NSSet)

    @objc(removeShows:)
    @NSManaged public func removeFromShows(_ values: NSSet)

}

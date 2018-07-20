//
//  TunerChannel+CoreDataProperties.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/7/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreData


extension TunerChannel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TunerChannel> {
        return NSFetchRequest<TunerChannel>(entityName: "TunerChannel")
    }

    @NSManaged public var active: NSNumber?
    @NSManaged public var callsign: String?
    @NSManaged public var favorite: NSNumber?
    @NSManaged public var frequency: NSNumber?
    @NSManaged public var number: NSNumber?
    @NSManaged public var seen: NSNumber?
    @NSManaged public var standardsTable: String?
    @NSManaged public var utcOffset: NSNumber?
    @NSManaged public var virtualMajorChannelNumber: NSNumber?
    @NSManaged public var ratings: NSSet?
    @NSManaged public var subchannels: NSSet?

}

// MARK: Generated accessors for ratings
extension TunerChannel {

    @objc(addRatingsObject:)
    @NSManaged public func addToRatings(_ value: Rating)

    @objc(removeRatingsObject:)
    @NSManaged public func removeFromRatings(_ value: Rating)

    @objc(addRatings:)
    @NSManaged public func addToRatings(_ values: NSSet)

    @objc(removeRatings:)
    @NSManaged public func removeFromRatings(_ values: NSSet)

}

// MARK: Generated accessors for subchannels
extension TunerChannel {

    @objc(addSubchannelsObject:)
    @NSManaged public func addToSubchannels(_ value: TunerSubchannel)

    @objc(removeSubchannelsObject:)
    @NSManaged public func removeFromSubchannels(_ value: TunerSubchannel)

    @objc(addSubchannels:)
    @NSManaged public func addToSubchannels(_ values: NSSet)

    @objc(removeSubchannels:)
    @NSManaged public func removeFromSubchannels(_ values: NSSet)

}

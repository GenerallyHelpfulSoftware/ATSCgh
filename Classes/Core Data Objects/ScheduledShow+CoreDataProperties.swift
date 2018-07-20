//
//  ScheduledShow+CoreDataProperties.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/7/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreData


extension ScheduledShow {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScheduledShow> {
        return NSFetchRequest<ScheduledShow>(entityName: "ScheduledShow")
    }

    @NSManaged public var calendarID: String?
    @NSManaged public var end_time: NSDate?
    @NSManaged public var event_id: NSNumber?
    @NSManaged public var eventBlock: NSNumber?
    @NSManaged public var start_time: NSDate?
    @NSManaged public var version: NSNumber?
    @NSManaged public var contentAdvisories: NSSet?
    @NSManaged public var descriptions: NSSet?
    @NSManaged public var subChannel: TunerSubchannel?
    @NSManaged public var titles: NSSet?

}

// MARK: Generated accessors for contentAdvisories
extension ScheduledShow {

    @objc(addContentAdvisoriesObject:)
    @NSManaged public func addToContentAdvisories(_ value: ContentAdvisory)

    @objc(removeContentAdvisoriesObject:)
    @NSManaged public func removeFromContentAdvisories(_ value: ContentAdvisory)

    @objc(addContentAdvisories:)
    @NSManaged public func addToContentAdvisories(_ values: NSSet)

    @objc(removeContentAdvisories:)
    @NSManaged public func removeFromContentAdvisories(_ values: NSSet)

}

// MARK: Generated accessors for descriptions
extension ScheduledShow {

    @objc(addDescriptionsObject:)
    @NSManaged public func addToDescriptions(_ value: ShowDescription)

    @objc(removeDescriptionsObject:)
    @NSManaged public func removeFromDescriptions(_ value: ShowDescription)

    @objc(addDescriptions:)
    @NSManaged public func addToDescriptions(_ values: NSSet)

    @objc(removeDescriptions:)
    @NSManaged public func removeFromDescriptions(_ values: NSSet)

}

// MARK: Generated accessors for titles
extension ScheduledShow {

    @objc(addTitlesObject:)
    @NSManaged public func addToTitles(_ value: ShowTitle)

    @objc(removeTitlesObject:)
    @NSManaged public func removeFromTitles(_ value: ShowTitle)

    @objc(addTitles:)
    @NSManaged public func addToTitles(_ values: NSSet)

    @objc(removeTitles:)
    @NSManaged public func removeFromTitles(_ values: NSSet)

}

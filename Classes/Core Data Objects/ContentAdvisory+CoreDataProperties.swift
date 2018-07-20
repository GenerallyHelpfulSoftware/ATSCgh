//
//  ContentAdvisory+CoreDataProperties.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/7/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreData


extension ContentAdvisory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContentAdvisory> {
        return NSFetchRequest<ContentAdvisory>(entityName: "ContentAdvisory")
    }

    @NSManaged public var rating_region: NSNumber?
    @NSManaged public var eventRatings: NSSet?
    @NSManaged public var ratingDescriptions: NSSet?
    @NSManaged public var show: ScheduledShow?

}

// MARK: Generated accessors for eventRatings
extension ContentAdvisory {

    @objc(addEventRatingsObject:)
    @NSManaged public func addToEventRatings(_ value: EventRating)

    @objc(removeEventRatingsObject:)
    @NSManaged public func removeFromEventRatings(_ value: EventRating)

    @objc(addEventRatings:)
    @NSManaged public func addToEventRatings(_ values: NSSet)

    @objc(removeEventRatings:)
    @NSManaged public func removeFromEventRatings(_ values: NSSet)

}

// MARK: Generated accessors for ratingDescriptions
extension ContentAdvisory {

    @objc(addRatingDescriptionsObject:)
    @NSManaged public func addToRatingDescriptions(_ value: RatingDescription)

    @objc(removeRatingDescriptionsObject:)
    @NSManaged public func removeFromRatingDescriptions(_ value: RatingDescription)

    @objc(addRatingDescriptions:)
    @NSManaged public func addToRatingDescriptions(_ values: NSSet)

    @objc(removeRatingDescriptions:)
    @NSManaged public func removeFromRatingDescriptions(_ values: NSSet)

}

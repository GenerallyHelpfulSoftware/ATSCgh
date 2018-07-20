//
//  Rating+CoreDataProperties.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/7/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreData


extension Rating {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rating> {
        return NSFetchRequest<Rating>(entityName: "Rating")
    }

    @NSManaged public var index: NSNumber?
    @NSManaged public var isGraduated: NSNumber?
    @NSManaged public var channel: TunerChannel?
    @NSManaged public var titles: NSSet?

}

// MARK: Generated accessors for titles
extension Rating {

    @objc(addTitlesObject:)
    @NSManaged public func addToTitles(_ value: RatingTitle)

    @objc(removeTitlesObject:)
    @NSManaged public func removeFromTitles(_ value: RatingTitle)

    @objc(addTitles:)
    @NSManaged public func addToTitles(_ values: NSSet)

    @objc(removeTitles:)
    @NSManaged public func removeFromTitles(_ values: NSSet)

}

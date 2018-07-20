//
//  EventRating+CoreDataProperties.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/7/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreData


extension EventRating {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventRating> {
        return NSFetchRequest<EventRating>(entityName: "EventRating")
    }

    @NSManaged public var ratingIndex: NSNumber?
    @NSManaged public var ratingValue: NSNumber?
    @NSManaged public var advisory: ContentAdvisory?

}

//
//  RatingDescription+CoreDataProperties.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/7/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreData


extension RatingDescription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RatingDescription> {
        return NSFetchRequest<RatingDescription>(entityName: "RatingDescription")
    }

    @NSManaged public var advisory: ContentAdvisory?

}

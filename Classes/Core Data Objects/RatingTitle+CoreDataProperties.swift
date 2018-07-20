//
//  RatingTitle+CoreDataProperties.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/7/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreData


extension RatingTitle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RatingTitle> {
        return NSFetchRequest<RatingTitle>(entityName: "RatingTitle")
    }

    @NSManaged public var rating: Rating?

}

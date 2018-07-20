//
//  ShowDescription+CoreDataProperties.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/7/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreData


extension ShowDescription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShowDescription> {
        return NSFetchRequest<ShowDescription>(entityName: "ShowDescription")
    }

    @NSManaged public var show: ScheduledShow?

}

//
//  ShowTitle+CoreDataProperties.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/7/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreData


extension ShowTitle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShowTitle> {
        return NSFetchRequest<ShowTitle>(entityName: "ShowTitle")
    }

    @NSManaged public var show: ScheduledShow?

}

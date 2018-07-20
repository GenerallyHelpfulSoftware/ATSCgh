//
//  LocalizedString+CoreDataProperties.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/7/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreData


extension LocalizedString {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalizedString> {
        return NSFetchRequest<LocalizedString>(entityName: "LocalizedString")
    }

    @NSManaged public var locale: String?
    @NSManaged public var text: String?

}

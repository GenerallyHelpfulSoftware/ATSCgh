//
//  Rating+TV.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/7/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreData


public extension Rating
{
    public static func extractRatings(fromRatingTable ratingTable : RatingRegionTable, intoChannel theChannel: TunerChannel)
    {
        guard let context = theChannel.managedObjectContext else
        {
            return
        }
        context.performAndWait {
            
            var index = 0
            let ratingTitleEntity = NSEntityDescription.entity(forEntityName: "RatingTitle", in: context)!
            let ratingEntity = NSEntityDescription.entity(forEntityName: "Rating", in: context)!
            let ratings = ratingTable.rating_dimensions.map{ (ratingDimension) -> Rating in
                let aRating = Rating(entity: ratingEntity, insertInto: context)
                aRating.index = NSNumber(value: index)
                index += 1
                aRating.channel = theChannel
                aRating.isGraduated = NSNumber(value: ratingDimension.isGraduatedScale)
                if let names = ratingDimension.names
                {
                    let titles = names.map{ (aString) -> RatingTitle in
                        let aTitle = RatingTitle(entity: ratingTitleEntity, insertInto: context)
                        aTitle.locale = aString.languageCode
                        aTitle.text = aString.string
                        aTitle.rating = aRating
                        return aTitle
                    }
                aRating.addToTitles(NSSet(array: titles))
                }
                return aRating
            }
            theChannel.addToRatings(Set<Rating>(ratings) as NSSet)
        }
    }
    
    public static func update(ratings: Set<Rating>, fromRatingTable ratingTable: RatingRegionTable)
    {
        guard ratings.count == ratingTable.rating_dimensions.count else
        {
            return
        }
        
        
        guard let context = ratings.first?.managedObjectContext else
        {
            return
        }
        
        context.performAndWait {
            let oldRatings = [Rating](ratings).sorted { (rating0, rating1) -> Bool in
                guard let index0 = rating0.index?.intValue, let index1 = rating1.index?.intValue else
                {
                    return rating0.index != rating1.index && rating0.index != nil
                }
                return index0 > index1
            }
            var index = 0
            for aDimension in ratingTable.rating_dimensions
            {
                let aRating = oldRatings[index]
                index += 1
                if (aRating.isGraduated?.boolValue ?? false) != aDimension.isGraduatedScale
                {
                    aRating.isGraduated = NSNumber(value: aDimension.isGraduatedScale)
                }
                
                var stringsToAdd = aDimension.names 
                if let ratingTitles = aRating.titles as? Set<RatingTitle>
                {
                    var titlesToRemove : [RatingTitle]? = nil
                    
                    for aTitle in ratingTitles
                    {
                        let locale = aTitle.locale
                        let text = aTitle.text
                        var foundIt = false
                        if let names = aDimension.names
                        {
                            for aString in names
                            {
                                if locale == aString.languageCode
                                {
                                    foundIt = true
                                    if text != aString.string
                                    {
                                        aTitle.text = aString.string
                                    }
                                    stringsToAdd = stringsToAdd?.filter{testString in
                                        testString != aString}
                                    break
                                }
                            }
                        }
                        if !foundIt
                        {
                            if titlesToRemove == nil
                            {
                                titlesToRemove = [aTitle]
                            }
                            else
                            {
                                titlesToRemove!.append(aTitle)
                            }
                        }
                    }
                    if let removeThis = titlesToRemove
                    {
                        aRating.removeFromTitles(Set<RatingTitle>(removeThis) as NSSet)
                    }
                }
                if stringsToAdd?.count ?? 0 > 0
                {
                    let ratingTitleEntity = NSEntityDescription.entity(forEntityName: "RatingTitle", in: context)!
                    for aLanguageString in stringsToAdd!
                    {
                        let newTitle = RatingTitle(entity: ratingTitleEntity, insertInto: context)
                        newTitle.locale = aLanguageString.languageCode
                        newTitle.text = aLanguageString.string
                        newTitle.rating = aRating
                        aRating.addToTitles(newTitle)
                    }
                }

            }
        }
    }
}

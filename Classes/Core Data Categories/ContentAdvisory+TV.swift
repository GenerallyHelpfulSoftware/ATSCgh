//
//  ContentAdvisory+TV.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/7/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreData

public extension ContentAdvisory
{
    public static func extractAdvisories(fromDescriptors advisoryDescriptor: ContentAdvisoryDescriptor, intoShow show: ScheduledShow)
    {
        guard let context = show.managedObjectContext else
        {
            return
        }
        context.performAndWait
        {
            let contentAdvisoryEntity = NSEntityDescription.entity(forEntityName: "ContentAdvisory", in: context)!
            let ratingDescriptionEntity = NSEntityDescription.entity(forEntityName: "RatingDescription", in: context)!
            
            let eventRatingEntity = NSEntityDescription.entity(forEntityName: "EventRating", in: context)!
            
            
            let advisories = advisoryDescriptor.rating_regions.map{ aRegion -> ContentAdvisory in
                
                let anAdvisory = ContentAdvisory(entity: contentAdvisoryEntity, insertInto: context)
                anAdvisory.rating_region = NSNumber(value: aRegion.rating_region)
                
                var index = 0
                let eventRatings = aRegion.eventRatingDimensions.map
                {(aDimension) ->EventRating in
                    let anEventRating = EventRating(entity: eventRatingEntity, insertInto: context)
                    anEventRating.ratingIndex = NSNumber(value: index)
                    index += 1
                    let ratingValue = aDimension.rating_value
                    anEventRating.ratingValue = NSNumber(value: ratingValue)
                    anEventRating.advisory = anAdvisory
                    return anEventRating
                }
                anAdvisory.addToEventRatings(NSSet(array: eventRatings))
                
                
                let descriptions = aRegion.rating_descriptions.map { (aLanguageString) -> RatingDescription in
                    let aDescription = RatingDescription(entity: ratingDescriptionEntity, insertInto: context)
                    aDescription.locale = aLanguageString.languageCode
                    aDescription.text = aLanguageString.string
                    aDescription.advisory = anAdvisory
                    return aDescription
                }
                
                anAdvisory.addToRatingDescriptions(NSSet(array: descriptions))
                
                anAdvisory.show = show
                return anAdvisory
            }
            show.addToContentAdvisories(NSSet(array: advisories))
        }
    }
    public static func retrieveBestMatch(fromAdvisories advisories: Set<ContentAdvisory>) -> ContentAdvisory?
    {
        return advisories.first // TODO, be more selective
    }
    
    public func advisoryString(givenRatings ratings : Set<Rating>) -> String?
    {
        var result : String? = nil
        self.managedObjectContext?.performAndWait {
            if (self.ratingDescriptions?.count)! > 0
            {
                result = LocalizedString.bestMatch(fromSet: self.ratingDescriptions as! Set<LocalizedString>)
            }
            guard let eventRatings = self.eventRatings as? Set<EventRating> else
            {
                return
            }
            let sortedRatings = ratings.sorted(by: { (rating1, rating2) -> Bool in
                guard let index1 = rating1.index?.intValue, let index2 = rating2.index?.intValue else
                {
                    return rating1.index != rating2.index && rating1.index != nil
                }
                return index1 < index2
            })
            
            for anEventRating in eventRatings
            {
                let whichDimension = anEventRating.ratingIndex?.intValue
                if whichDimension ?? 0 < sortedRatings.count
                {
                    let theRating = sortedRatings[whichDimension ?? 0]
                    if let theTitle = LocalizedString.bestMatch(fromSet: theRating.titles as! Set<LocalizedString>)
                    {
                        result = (result != nil) ? "\(result!) \(theTitle)" : theTitle
                    }
                    if theRating.isGraduated?.boolValue ?? false && anEventRating.ratingValue != nil
                    {
                        let ratingValue = anEventRating.ratingValue!.stringValue
                        result = (result != nil) ? "\(result!) ratingValue" : ratingValue
                    }
                }
            }
        }
        return result
    }
}

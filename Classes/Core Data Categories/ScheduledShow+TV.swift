//
//  ScheduledShow+TV.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/8/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreData
import CoreGraphics
import SVGgh

public extension ScheduledShow
{
    @objc public var networkIcon : SVGRenderer?
    {
        let result = self.subChannel?.networkIcon
        return result
    }
    

    
    @objc public var twitterText : String
    {
        var result = ""
        self.managedObjectContext?.performAndWait
        {
            let newLineString = "\n"
            var strings = Array<String>()
            if let title = self.title
            {
                strings.append(title)
            }
            
            
            if let subchannelDescription = self.subChannel?.completedDescription
            {
                strings.append(subchannelDescription)
            }
            
            if let description = self.showDescription
            {
                strings.append(description)
            }
            
            
            if let endDate = self.end_time, let startDate = self.start_time
            {
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .short
                dateFormatter.dateStyle = .medium
                
                dateFormatter.doesRelativeDateFormatting = true
                
                let timeZone = NSTimeZone.system
                
                
                let starts = NSLocalizedString("Starts: ", comment: "") + dateFormatter.string(from: (startDate as Date) as Date) + " " + timeZone.localizedName(for: timeZone.isDaylightSavingTime() ? .shortDaylightSaving : .shortStandard , locale: NSLocale.system)!
                let length = Int(floor(endDate.timeIntervalSince(startDate as Date)/60.0))
                let lasts = NSLocalizedString("Lasts: ", comment: "") + String(length) + NSLocalizedString(" min", comment: "")
                strings.append(starts)
                strings.append(lasts)

            }
            
            for aString in strings
            {
                let length = aString.count
                let runningLength = result.count
                let addedLength = (runningLength > 0) ? length+1 : length
                if (addedLength + runningLength) > 280
                {
                    continue
                }
                else if runningLength > 0
                {
                    result += newLineString
                    result += aString
                }
                else
                {
                    result = aString
                }
                
            }
            
        }
        return result
    }
    
    @objc public var shareableText : NSAttributedString
    {
        let mutableResult = NSMutableAttributedString()
        
        self.managedObjectContext?.performAndWait {
            let headerFont = UIFont.preferredFont(forTextStyle: .headline)
            let textFont = UIFont.preferredFont(forTextStyle: .body)
            let captionFont = UIFont.preferredFont(forTextStyle: .caption1)
            let captionDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .caption1)
            let boldCaptionDescriptor = captionDescriptor.withSymbolicTraits(.traitBold) ?? captionDescriptor
            let boldCaptionFont = UIFont(descriptor: boldCaptionDescriptor, size: 0.0)
            let headerDescription = [NSAttributedStringKey.font : headerFont]
            let textDescription = [NSAttributedStringKey.font : textFont]
            let captionDescription = [NSAttributedStringKey.font :  captionFont]
            let caption2Description = [NSAttributedStringKey.font : boldCaptionFont]
            
            if let title = self.title
            {
                let titleString = NSAttributedString(string: title, attributes: headerDescription)
                mutableResult.append(titleString)
            }
            if let description = self.showDescription
            {
                let addedString = "\n" + description
                let descriptionString = NSAttributedString(string: addedString, attributes: textDescription)
                mutableResult.append((descriptionString))
            }
            
            if let endDate = self.end_time, let startDate = self.start_time
            {
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .short
                dateFormatter.dateStyle = .medium
                
                dateFormatter.doesRelativeDateFormatting = true
                
                let timeZone = NSTimeZone.system
                
                mutableResult.append(NSAttributedString(string: "\n"))
                mutableResult.append(NSAttributedString(string: NSLocalizedString("Starts: ", comment:""), attributes: caption2Description))
                
                let starts = dateFormatter.string(from: (startDate as Date) as Date) + " " + timeZone.localizedName(for: timeZone.isDaylightSavingTime() ? .shortDaylightSaving : .shortStandard , locale: NSLocale.system)!
                mutableResult.append(NSAttributedString(string: starts, attributes: captionDescription))
                
                
                mutableResult.append(NSAttributedString(string: "\n"))
                mutableResult.append(NSAttributedString(string: NSLocalizedString("Lasts: ", comment:""), attributes: caption2Description))
                
                let length = Int(floor(endDate.timeIntervalSince(startDate as Date)/60.0))
                let lasts = String(length) + NSLocalizedString(" min", comment: "")
                mutableResult.append(NSAttributedString(string: lasts, attributes: captionDescription))
            }
        }
        
        return mutableResult.copy() as! NSAttributedString
    }
    
    @objc public var title : String?
    {
        var result : String? = nil
        self.managedObjectContext?.performAndWait {
            guard  let titles = self.titles as?  Set<LocalizedString> else
            {
                return
            }
            result = LocalizedString.bestMatch(fromSet: titles )
        }
        return result
    }
    
    public var advisoryString : String?
    {
        var result : String? = nil
        self.managedObjectContext?.performAndWait {
            guard  let advisories = self.contentAdvisories, let relevantContentAdvisory = ContentAdvisory.retrieveBestMatch(fromAdvisories: advisories as! Set<ContentAdvisory>), let ratings = self.subChannel?.channel?.ratings as? Set<Rating> else
            {
                return
            }
            result = relevantContentAdvisory.advisoryString(givenRatings: ratings)
        }
        return result
    }
    
    public var showDescription : String?
    {
        var result : String? = nil
        self.managedObjectContext?.performAndWait {
            guard  let descriptions = self.descriptions else
            {
                return
            }
            result = LocalizedString.bestMatch(fromSet: descriptions as! Set<LocalizedString>)
        }
        return result
    }
    
    @nonobjc static var timeFormatter : DateFormatter =
    {
        var result = DateFormatter()
        result.timeStyle = .short
        result.dateStyle = .medium
        result.doesRelativeDateFormatting = true
        return result
    }()
    
    public var startTimeString : String?
    {
        var result : String? = nil
        self.managedObjectContext?.performAndWait {
            guard  let startTime = self.start_time else
            {
                return
            }
            let now = Date()
            let seconds = startTime.timeIntervalSinceNow
            let minutes = rint(seconds/60)
            let intMinutes = Int(minutes)
            let deltaMinutes = abs(intMinutes)
            
            switch (startTime.compare(now), minutes)
            {
                case (.orderedDescending, 0), (.orderedSame, _):
                    result = NSLocalizedString("Starting Now", comment: "")
                case (.orderedDescending, 1):
                    result = NSLocalizedString("Starts in a minute", comment: "")
                case (.orderedDescending, 2..<60):
                    let template = NSLocalizedString("Starts in %d minutes", comment: "")
                    
                    result = String(format: template, intMinutes)
                case (.orderedDescending, _):
                    let endDateString = ScheduledShow.timeFormatter.string(from: startTime as Date)
                    let formatString = NSLocalizedString("Starts %@", comment: "")
                    result = String(format: formatString, endDateString)
                case (.orderedAscending, 0):
                    result = NSLocalizedString("Just Started", comment: "")
                case (.orderedAscending, -1):
                    result = NSLocalizedString("Started a minute ago", comment: "")
                case (.orderedAscending, -59..<0):
                    let template = NSLocalizedString("Started %d minutes ago", comment: "")
                    result = String(format: template, deltaMinutes)
                case (.orderedAscending, _):
                    let endDateString = ScheduledShow.timeFormatter.string(from: startTime as Date)
                    let formatString = NSLocalizedString("Started %@", comment: "")
                    result = String(format: formatString, endDateString)
            }
        }
        return result
    }
    
    public func bridges(date testDate: NSDate) -> Bool
    {
        var result = false
        self.managedObjectContext?.performAndWait {
            guard let endTime = self.end_time, let startTime = self.start_time else
            {
                return
            }
            switch (endTime.compare(testDate as Date), startTime.compare(testDate as Date))
            {
                case (.orderedAscending, _), (_, .orderedDescending):
                    result = false
                default:
                    result = true
            }
        }
        return result
    }
    
    public var endTimeString : String?
    {
        var result: String? = nil
        let now = Date()
        let bridgesDate = self.bridges(date: now as NSDate)
        
        self.managedObjectContext?.performAndWait
        {
            guard let endTime = self.end_time else
            {
                return
            }
            
            if bridgesDate
            {
                let seconds = endTime.timeIntervalSinceNow
                let minutes = rint(seconds/60)
                let intMinutes = Int(minutes)
                switch(intMinutes)
                {
                    case 0:
                        result = NSLocalizedString("Ends now", comment: "")
                    case 1:
                        result = NSLocalizedString("Ends this minute", comment: "")
                    default:
                        let template = NSLocalizedString("Ends in %d minutes", comment: "")
                        result = String(format: template, intMinutes)
                }
            }
            else
            {
                let endDateString = ScheduledShow.timeFormatter.string(from: endTime as Date)
                switch endTime.compare(now as Date)
                {
                    case .orderedAscending:
                        let formatString = NSLocalizedString("Ended %@", comment: "")
                        result = String(format: formatString, endDateString)
                    default:
                            let formatString = NSLocalizedString("Ends %@", comment: "")
                    result = String(format: formatString, endDateString)
                    
                }
            }
            
        }
        return result
    }
    
    @nonobjc static func startDate(fromEventRecord eventRecord: EventInformationRecord, withTimeOffset timeOffset: TimeInterval) -> Date
    {
        let startTime = eventRecord.start_time
        let dateTime = startTime+timeOffset + SystemTimeTable.beginningOf1980()
        let baseResult = Date(timeIntervalSince1970: dateTime)
        let result = baseResult.dateAtNearestMinute
        return result
    }
    
    @nonobjc static func endDate(fromEventRecord eventRecord: EventInformationRecord, withTimeOffset timeOffset: TimeInterval) -> Date
    {
        let startTime = ScheduledShow.startDate(fromEventRecord: eventRecord, withTimeOffset: timeOffset)
        let result = startTime.addingTimeInterval(eventRecord.length_in_seconds)
        return result
    }
    
//    +(NSDate*) startDateFromEventRecord:(EventInformationRecord*)eventRecord withTimeOffest:(NSTimeInterval)timeOffset
//    {
//    NSTimeInterval startTime = eventRecord.start_time;
//
//    NSTimeInterval dateTime = startTime+timeOffset+[SystemTimeTable beginningOf1980];
//    NSDate* result = [[NSDate alloc] initWithTimeIntervalSince1970:dateTime];
//    result = [result dateAtNearestMinute];
//    return result;
//    }
//
//    +(NSDate*) endDateFromEventRecord:(EventInformationRecord*)eventRecord withTimeOffest:(NSTimeInterval)timeOffset
//    {
//    NSDate* start_time = [ScheduledShow startDateFromEventRecord:eventRecord withTimeOffest:timeOffset];
//
//    NSDate* result = [start_time dateByAddingTimeInterval:eventRecord.length_in_seconds];
//    return result;
//    }

    
    public func update(fromEventRecord eventRecord: EventInformationRecord, withTimeOffset timeOffset: TimeInterval)
    {
        guard let context = self.managedObjectContext else
        {
            return
        }
        
        context.performAndWait {
            let startTime = eventRecord.start_time
            let dateTime = startTime+timeOffset+SystemTimeTable.beginningOf1980()
            let start_date = Date(timeIntervalSince1970: dateTime).dateAtNearestMinute
            if let originalStartTime = self.start_time
            {
                if fabs(originalStartTime.timeIntervalSince(start_date)) > 120.0
                {
                        self.start_time = start_date as NSDate
                }
            }
            else
            {
                self.start_time = start_date as NSDate
            }
            
            let endTime = start_date.addingTimeInterval(eventRecord.length_in_seconds)
            self.end_time = endTime as NSDate
            self.event_id = NSNumber(value: eventRecord.event_id)
            let showTitleEntity = NSEntityDescription.entity(forEntityName: "ShowTitle", in: context)!
            for aLanguageString in eventRecord.workingTitles()
            {
                var foundIt = false
                if let titles = self.titles as? Set<LocalizedString>
                {
                    for aTitle in titles
                    {
                        if aTitle.locale == aLanguageString.languageCode
                        {
                            foundIt = true
                            aTitle.text = aLanguageString.string
                            break
                        }
                    }
                }
                if !foundIt
                {
                    let newTitle = ShowTitle(entity: showTitleEntity, insertInto: context)
                    newTitle.locale = aLanguageString.languageCode
                    newTitle.text = aLanguageString.string
                    newTitle.show = self
                    self.addToTitles(newTitle)
                }
                
                if self.contentAdvisories?.count == 0
                {
                    for aTable in eventRecord.descriptors
                    {
                        if let contentAdvisoryDescriptor = aTable as? ContentAdvisoryDescriptor
                        {
                            ContentAdvisory.extractAdvisories(fromDescriptors : contentAdvisoryDescriptor, intoShow: self)
                        }
                    }
                }
            }
            
        }
    }
    public func update(fromExtendedTextTable extendedText : ExtendedTextTable)
    {
        guard let context = self.managedObjectContext else
        {
            return
        }
        context.performAndWait {
            let showDescriptionEntity = NSEntityDescription.entity(forEntityName: "ShowDescription", in: context)!
            for aLanguageString in extendedText.strings
            {
                var foundIt = false
                if let descriptions = self.descriptions as? Set<LocalizedString>
                {
                    for aDescription in descriptions
                    {
                        if aDescription.locale == aLanguageString.languageCode && !aLanguageString.string.isEmpty
                        {
                            foundIt = true
                            aDescription.text = aLanguageString.string
                        }
                    }
                }
                if !foundIt
                {
                    let newDescription = ShowDescription(entity: showDescriptionEntity, insertInto: context)
                    
                    newDescription.locale = aLanguageString.languageCode
                    newDescription.text = aLanguageString.string
                    newDescription.show = self
                    self.addToDescriptions(newDescription)
                }
            }
        }
    }
}

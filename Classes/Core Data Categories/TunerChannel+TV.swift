//
//  TunerChannel+TV.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/16/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation

extension TunerChannel
{
    @objc public var trimmedCallsign : String?
    {
        var result : String? = nil
        self.managedObjectContext?.performAndWait {
            if let theCallSign = self.callsign
            {
                result = theCallSign
                if let hyphenRange = result?.range(of: "-")
                {
                    result = String(result!.prefix(upTo: hyphenRange.lowerBound))
                }
            }
            
        }
        
        return result
    }
    
    public var tower : Tower?
    {
        var result : Tower? = nil
        self.managedObjectContext?.performAndWait {
            guard let myCallSign = self.callsign, !myCallSign.isEmpty else
            {
                return
            }
            var activeCallsign = myCallSign
            if activeCallsign.hasSuffix("SD1")
            {
                activeCallsign = activeCallsign.replacingOccurrences(of: "SD1", with: "-TV")
            }
            else if activeCallsign.hasSuffix("-HD")
            {
                activeCallsign = activeCallsign.replacingOccurrences(of: "-HD", with: "-TV")
            }
            else if activeCallsign.hasSuffix("-SD")
            {
                activeCallsign = activeCallsign.replacingOccurrences(of: "-SD", with: "-TV")
            }
            else if activeCallsign.hasSuffix("-DT")
            {
                activeCallsign = activeCallsign.replacingOccurrences(of: "-DT", with: "-TV")
            }
            else if !activeCallsign.hasSuffix("-TV") && !activeCallsign.contains("-")
            {
                activeCallsign = activeCallsign + "-TV"
            }
            result = BroadcasterModel.shared().tower(withCallSign: activeCallsign)
            
        }
        
        return result
    }
    
    @objc public var network : Network?
    {
        var result : Network? = nil
        var networkName : String? = nil
        self.managedObjectContext?.performAndWait {
            if let subChannels = self.subchannels as? Set<TunerSubchannel>
            {
                for aSubChannel in subChannels
                {
                    if aSubChannel.virtualMinorChannelNumber == 1
                    {
                        result = aSubChannel.network
                        if aSubChannel.network?.isMajor ?? false
                        {
                            break
                        }
                    }
                    else if result != nil && aSubChannel.network?.isMajor ?? false
                    {
                        result = aSubChannel.network
                        break
                    }
                }
                if result == nil
                {
                    if let tower = self.tower
                    {
                        let broadcaster = tower.broadcaster
                        result = broadcaster?.networks?.anyObject() as? Network
                    }
                }
                networkName = self.callsign
            }
        }
        if result == nil && !(networkName?.isEmpty ?? false)
        {
            if let theName = networkName
            {
                result = BroadcasterModel.shared().networkNamed(theName)
            }
        }
        return result 
    }
    
    public func network(forMinorChannelNumber minorChannelNumber: Int) -> Network?
    {
        var result : Network? = nil
        self.managedObjectContext?.performAndWait {
            guard let subChannels = self.subchannels as? Set<TunerSubchannel> else
            {
                return
            }
            for aSubChannel in subChannels
            {
                if aSubChannel.virtualMinorChannelNumber?.intValue == minorChannelNumber
                {
                    result = aSubChannel.network
                    break
                }
            }
        }
        return result
    }
    
    public func subChannel(withMinorChannelNumber minorChannelNumber : Int) -> TunerSubchannel?
    {
        var result : TunerSubchannel? = nil
        self.managedObjectContext?.performAndWait {
            guard let subChannels = self.subchannels as? Set<TunerSubchannel> else
            {
                return
            }
            var lowestSubChannel : TunerSubchannel? = nil
            
            var majorSubChannel : TunerSubchannel? = nil
            for subChannel in subChannels
            {
                if subChannel.virtualMinorChannelNumber?.intValue == minorChannelNumber
                {
                    result = subChannel
                    return
                }
                else if lowestSubChannel == nil
                {
                    lowestSubChannel = subChannel
                }
                else
                {
                    switch (lowestSubChannel!.virtualMinorChannelNumber, subChannel.virtualMinorChannelNumber)
                    {
                        case (.some(let lowestSoFar), .some(let test)):
                            if lowestSoFar.intValue > test.intValue
                            {
                                lowestSubChannel = subChannel
                            }
                        case (.none, .some):
                            lowestSubChannel = subChannel
                        default:
                            break
                        
                    }
                }
                if majorSubChannel == nil
                {
                    if subChannel.network?.isMajor ?? false
                    {
                        majorSubChannel = subChannel
                    }
                }
            }
            if result == nil && minorChannelNumber == 0
            {
                if majorSubChannel != nil
                {
                    result = majorSubChannel
                    
                }
                else
                {
                    result = lowestSubChannel
                }
            }
        }
        return result
    }
    
    @objc public func extract(atscTables:[String : ATSCTable])
    {
        self.managedObjectContext?.performAndWait {
            for (_, table) in atscTables
            {
                if let ratingTable = table as? RatingRegionTable
                {
                    if self.ratings?.count != ratingTable.rating_dimensions.count
                    {
                        Rating.extractRatings(fromRatingTable: ratingTable, intoChannel: self)
                    }
                    else if let ratings = self.ratings as? Set<Rating>, ratings.count > 0
                    {
                        Rating.update(ratings: ratings, fromRatingTable: ratingTable)
                    }
                }
            }
        }
    }
    
    @objc public func configure(fromStandardDescription description: [String: AnyObject])
    {
        self.managedObjectContext?.performAndWait {
            self.frequency = description[kTunerFrequencyTag] as? NSNumber
            self.standardsTable = description[kChannelMapStandardTag] as? String
            self.number = description[kRealChannelTag] as? NSNumber
        }
    }
}

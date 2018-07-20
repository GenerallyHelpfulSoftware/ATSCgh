//
//  NSDate+DigitalTV.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/8/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation


public extension Date
{
    public static func startTimeNearestMinute(toDate baseTime: Date) -> UInt64
    {
        let seconds = rint(baseTime.timeIntervalSince1970)
        var result : UInt64 = UInt64(seconds)+30
        result /= 60
        result *= 60
        return result
    }
    
    public var dateAtNearestMinute : Date
    {
        let timeIntervalNearestMinute = TimeInterval(Date.startTimeNearestMinute(toDate: self))
        guard self.timeIntervalSince1970 != timeIntervalNearestMinute else
        {
            return self
        }
        return Date(timeIntervalSince1970: timeIntervalNearestMinute)
    }

}

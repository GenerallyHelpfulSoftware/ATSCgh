//
//  ScheduledShow+Calendar.swift
//  Signal GH
//
//  Created by Glenn Howes on 7/4/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation
import EventKit
extension ScheduledShow
{
    @objc public func removeFromCalender(withCallback callback: @escaping (Bool, Error?) -> Void)
    {
        self.managedObjectContext?.perform
            {
                guard let calendarID = self.calendarID else
                {
                    return
                }
                let store = EKEventStore()
                store.requestAccess(to: .event)
                {
                    granted, error in
                    if granted
                    {
                        if let event = store.event(withIdentifier: calendarID)
                        {
                            try? store.remove(event, span: .thisEvent, commit: true)
                        }
                        self.managedObjectContext?.perform
                            {
                                self.calendarID = nil
                                
                                callback(error == nil, error)
                        }
                    }
                    else
                    {
                        callback(false, nil)
                    }
                }
        }
    }
    
    @objc public func addToCalender(withCallback callback: @escaping (Bool, Error?) -> Void)
    {
        let store = EKEventStore()
        store.requestAccess(to: .event)
        {
            granted, error in
            if granted
            {
                self.managedObjectContext?.perform
                    {
                        let event = EKEvent(eventStore: store)
                        if let title = self.title
                        {
                            event.title = title
                        }
                        if let startTime = self.start_time
                        {
                            event.startDate = startTime as Date
                            let anAlarm = EKAlarm(absoluteDate: startTime.addingTimeInterval(-60.0) as Date)
                            event.alarms = [anAlarm]
                        }
                        if let endTime = self.end_time
                        {
                            event.endDate = endTime as Date
                        }
                        event.calendar = store.defaultCalendarForNewEvents
                        do
                        {
                            try store.save(event, span: .thisEvent)
                            self.calendarID = event.eventIdentifier
                            callback(true, nil)
                        }
                        catch
                        {
                            callback(false, error)
                        }
                }
            }
            else
            {
                callback(false, nil)
            }
        }
    }
}

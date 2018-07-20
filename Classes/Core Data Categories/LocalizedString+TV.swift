//
//  LocalizedString+TV.swift
//  Signal GH
//
//  Created by Glenn Howes on 4/7/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
//

import Foundation

public extension LocalizedString
{
    public static func bestMatch(fromSet sourceStrings: Set<LocalizedString>) -> String?
    {
       // var bestMatch : LocalizedString? = nil
        guard sourceStrings.count > 0 else
        {
            return sourceStrings.first?.text
        }
        
        var defaultCodes : Set<String>?
        if let languageCode = NSLocale.current.languageCode
        {
            switch languageCode
            {
                case "en":
                    defaultCodes = Set<String>(["eng"])
                case "es":
                    defaultCodes = Set<String>(["spa"])
                case "fr":
                    defaultCodes = Set<String>(["fra", "fre"])
                default:
                    break
            }
        }
        guard let _ = defaultCodes else
        {
            return sourceStrings.first?.text
        }
        
        for aString in sourceStrings
        {
            if let locale = aString.locale
            {
                if defaultCodes?.contains(locale) ?? false
                {
                    return aString.text
                }
            }
        }
        
        return sourceStrings.first?.text
    }
}

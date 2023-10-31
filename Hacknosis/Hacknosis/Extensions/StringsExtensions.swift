//
//  StringsExtensions.swift
//  Core Content
//
//  Created by Jamie Klapwyk on 2021-07-16.
//

import Foundation

public extension String {
    ///Used to easily localize a string
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}

//
//  DateExtensions.swift
//  Core Content
//
//  Created by Gopireddy Amarnath Reddy on 06/04/23.
//

import Foundation

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }

    var weekday: Int {
        let calendar = Calendar.current
        return (calendar.component(.weekday, from: self) - calendar.firstWeekday + 7) % 7 + 1
    }
}

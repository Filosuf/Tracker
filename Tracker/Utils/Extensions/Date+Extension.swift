//
//  Date+Extension.swift
//  Tracker
//
//  Created by Filosuf on 13.02.2023.
//

import Foundation

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}

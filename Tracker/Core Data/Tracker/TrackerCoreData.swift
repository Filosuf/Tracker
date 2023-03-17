//
//  TrackerCoreData.swift
//  Tracker
//
//  Created by Filosuf on 10.03.2023.
//

import UIKit

extension TrackerCoreData {

    func toTracker() -> Tracker {
        let scheduleString = schedule ?? ""
        let scheduleStringArray = scheduleString.components(separatedBy: [" "])
        let scheduleArray = scheduleStringArray.compactMap { DayOfWeek(rawValue: $0) }
        return Tracker(id: id ?? "",
                       name: name ?? "",
                       color: color ?? UIColor.white,
                       emoji: emoji ?? "",
                       schedule: scheduleArray)
    }
}

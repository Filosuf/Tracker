//
//  TrackerCoreData.swift
//  Tracker
//
//  Created by Filosuf on 10.03.2023.
//

import UIKit

extension TrackerCoreData {

    var recordSorted: [TrackerRecordCoreData] {
        records?.sortedArray(using: [NSSortDescriptor(key: "date", ascending: true)]) as! [TrackerRecordCoreData]
    }

    func toTracker() -> Tracker {
        let scheduleString = schedule ?? ""
        let scheduleStringArray = scheduleString.components(separatedBy: [" "])
        let scheduleArray = scheduleStringArray.compactMap { DayOfWeek(rawValue: $0) }
        return Tracker(id: id ?? "",
                       name: name ?? "",
                       color: UIColor(hex: color) ?? UIColor.white,
                       emoji: emoji ?? "",
                       schedule: scheduleArray)
    }
}

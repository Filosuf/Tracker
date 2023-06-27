//
//  TrackerCoreData.swift
//  Tracker
//
//  Created by Filosuf on 10.03.2023.
//

import UIKit

extension TrackerCoreData {

    var recordSorted: [TrackerRecordCoreData] {
        let records = records?.sortedArray(using: [NSSortDescriptor(key: "date", ascending: true)]) as? [TrackerRecordCoreData]
        return records ?? []
    }

    func toTracker() -> Tracker {
        let scheduleString = schedule ?? ""
        let scheduleStringArray = scheduleString.components(separatedBy: [" "])
        let scheduleArray = scheduleStringArray.compactMap { DayOfWeek(rawValue: $0) }
        return Tracker(id: id ?? "",
                       name: name ?? "",
                       color: UIColor(hex: color) ?? UIColor.white,
                       emoji: emoji ?? "",
                       schedule: scheduleArray,
                       isPinned: isPinned,
                       categoryBeforePinned: categoryBeforePinned)
    }
}

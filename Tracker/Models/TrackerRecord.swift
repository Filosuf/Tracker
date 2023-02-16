//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Filosuf on 31.01.2023.
//

import Foundation

struct TrackerRecord: Equatable {
    let id: String
    let date: Date

    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        lhs.id == rhs.id &&
        lhs.date == rhs.date
    }
}

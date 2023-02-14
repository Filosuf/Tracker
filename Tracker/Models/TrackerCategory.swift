//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Filosuf on 31.01.2023.
//

import Foundation

struct TrackerCategory: Equatable {
    let title: String
    let trackers: [Tracker]

    static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        lhs.title == rhs.title
    }
}

//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Filosuf on 31.01.2023.
//

import Foundation

struct TrackerCategory: Hashable {
    let title: String
    let trackers: [Tracker]

    static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

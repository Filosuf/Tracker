//
//  Tracker .swift
//  Tracker
//
//  Created by Filosuf on 31.01.2023.
//

import UIKit

struct Tracker: Equatable {
    let id: String
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [DayOfWeek]
    let isPinned: Bool
    let categoryBeforePinned: String?

    static func == (lhs: Tracker, rhs: Tracker) -> Bool {
        lhs.id == rhs.id
    }

    static func < (lhs: Tracker, rhs: Tracker) -> Bool {
        lhs.name < rhs.name
    }

    init(id: String, name: String, color: UIColor, emoji: String, schedule: [DayOfWeek], isPinned: Bool = false, categoryBeforePinned: String? = nil) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isPinned = isPinned
        self.categoryBeforePinned = categoryBeforePinned
    }
}

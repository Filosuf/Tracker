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

    static func == (lhs: Tracker, rhs: Tracker) -> Bool {
        lhs.id == rhs.id
    }

    static func < (lhs: Tracker, rhs: Tracker) -> Bool {
        lhs.name < rhs.name
    }
}

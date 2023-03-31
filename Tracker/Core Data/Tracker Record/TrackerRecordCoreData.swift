//
//  TrackerRecordCoreData.swift
//  Tracker
//
//  Created by Filosuf on 21.03.2023.
//

import Foundation

extension TrackerRecordCoreData {

    func toTrackerRecord() -> TrackerRecord? {
        if let id = id, let date = date {
            return TrackerRecord(id: id, date: date)
        } else {
            return nil
        }
    }
}

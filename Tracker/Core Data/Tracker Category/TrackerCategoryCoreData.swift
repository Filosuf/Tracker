//
//  TrackerCategoryCoreData.swift
//  Tracker
//
//  Created by Filosuf on 10.03.2023.
//

import Foundation

extension TrackerCategoryCoreData {

    var trackersSorted: [TrackerCoreData] {
        trackers?.sortedArray(using: [NSSortDescriptor(key: "name", ascending: true)]) as! [TrackerCoreData]
    }
}

//
//  TrackerDataStore.swift
//  Tracker
//
//  Created by Filosuf on 17.03.2023.
//

import Foundation
import CoreData

protocol TrackerDataStore {
    var managedObjectContext: NSManagedObjectContext { get }
    func trackersIsEmpty() -> Bool
    func saveTracker(_ tracker: Tracker, titleCategory: String)
    func deleteTracker(_ tracker: Tracker)
}

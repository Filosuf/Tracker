//
//  TrackerCategoryDataStore.swift
//  Tracker
//
//  Created by Filosuf on 10.03.2023.
//

import Foundation
import CoreData

protocol TrackerCategoryDataStore {
    var managedObjectContext: NSManagedObjectContext { get }
    func add(_ trackerCategory: TrackerCategory)
//    func delete(_ record: NSManagedObject) throws
}

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
    func isDuplicateOfCategory(with title: String) -> Bool
    func updateCategoryTitle(previous: String, new: String)
//    func delete(_ record: NSManagedObject) throws
}

//
//  TrackerRecordDataStore.swift
//  Tracker
//
//  Created by Filosuf on 20.03.2023.
//

import Foundation
import CoreData

protocol TrackerRecordDataStore {
    var managedObjectContext: NSManagedObjectContext { get }
    func fetchRecords(trackerId: String) -> [TrackerRecordCoreData]?
    func addRecord(trackerId: String, date: Date)
    func deleteRecord(trackerId: String, date: Date)
}

//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Filosuf on 20.03.2023.
//

import Foundation
import CoreData

protocol TrackerRecordStoreProtocol {
    func fetchRecords(trackerId: String) -> [TrackerRecord]?
    func addRecord(trackerId: String, date: Date)
    func deleteRecord(trackerId: String, date: Date)
}

// MARK: - TrackerCategoryStore
final class TrackerRecordStore: NSObject {

    private let context: NSManagedObjectContext
    private let dataStore: TrackerRecordDataStore

    init(_ dataStore: TrackerRecordDataStore) {
        self.context = dataStore.managedObjectContext
        self.dataStore = dataStore
    }
}

// MARK: - DataProviderProtocol
extension TrackerRecordStore: TrackerRecordStoreProtocol {

    func fetchRecords(trackerId: String) -> [TrackerRecord]? {
        let recordsCoreData = dataStore.fetchRecords(trackerId: trackerId)
        let recordsOptional = recordsCoreData?.map { $0.toTrackerRecord() }
        let records = recordsOptional?.compactMap { $0 }
        return records
    }

    func addRecord(trackerId: String, date: Date) {
        dataStore.addRecord(trackerId: trackerId, date: date)
    }

    func deleteRecord(trackerId: String, date: Date) {
        dataStore.deleteRecord(trackerId: trackerId, date: date)
    }
}

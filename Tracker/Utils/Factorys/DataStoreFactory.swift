//
//  DataStoreFactory.swift
//  Tracker
//
//  Created by Filosuf on 17.03.2023.
//

import Foundation

final class DataStoreFactory {

    // MARK: - Properties
    let dataStore: TrackersRepository

    // MARK: - LifeCycle
    init(dataStore: TrackersRepository) {
        self.dataStore = dataStore
    }

    // MARK: - Methods
    func makeTrackerStore() -> TrackerStore {
        let store = TrackerStore(dataStore)
        return store
    }

    func makeTrackerCategoryStore() -> TrackerCategoryStore {
        let store = TrackerCategoryStore(dataStore)
        return store
    }

    func makeTrackerRecordsStore() -> TrackerRecordStore {
        let store = TrackerRecordStore(dataStore)
        return store
    }
}

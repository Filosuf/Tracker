//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Filosuf on 27.06.2023.
//

import XCTest
import SnapshotTesting
@testable import Tracker

class TrackerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testViewController() {
        let coordinator = TrackersFlowCoordinatorPlug()
        let trackerStore = TrackerStorePlug()
        let recordStore = TrackerRecordStorePlug()
        let vc = TrackersViewController(coordinator: coordinator, trackerStore: trackerStore, recordStore: recordStore) // 1

        assertSnapshot(matching: vc, as: .image)                                             // 2
    }

}

class TrackersFlowCoordinatorPlug: TrackersFlowCoordinatorProtocol {
    func showNewTracker() { }

    func showTrackerSettings(trackerStyle: TrackerStyle, indexPathEditTracker: IndexPath?) { }

    func showDeleteAlert(action: @escaping () -> Void) { }
}

class TrackerStorePlug: TrackerStoreProtocol {
    var numberOfSections = 0

    func updatePredicate(searchText: String?, dayOfWeek: String?) { }

    func numberOfRowsInSection(_ section: Int) -> Int { 0 }

    func sectionTitle(for section: Int) -> String { "" }

    func object(at: IndexPath) -> Tracker? { nil }

    func records(at indexPath: IndexPath) -> [TrackerRecord] { [] }

    func category(at indexPath: IndexPath) -> TrackerCategory? { nil }

    func trackersIsEmpty() -> Bool { true }

    func saveTracker(_ tracker: Tracker, titleCategory: String) { }

    func deleteTracker(at indexPath: IndexPath) { }
}

class TrackerRecordStorePlug: TrackerRecordStoreProtocol {
    func fetchRecords(trackerId: String) -> [TrackerRecord]? { nil }

    func addRecord(trackerId: String, date: Date) { }

    func deleteRecord(trackerId: String, date: Date) { }
}

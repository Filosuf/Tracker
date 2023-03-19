//
//  TrackerStore.swift
//  Tracker
//
//  Created by Filosuf on 17.03.2023.
//

import Foundation
import CoreData

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func sectionTitle(for section: Int) -> String
    func object(at: IndexPath) -> Tracker?
    func saveTracker(_ tracker: Tracker, titleCategory: String) throws
    func deleteTracker(at indexPath: IndexPath) throws
}

// MARK: - TrackerCategoryStore
final class TrackerStore: NSObject {

    enum DataProviderError: Error {
        case failedToInitializeContext
    }

    weak var delegate: TrackerStoreDelegate?

    private let context: NSManagedObjectContext
    private let dataStore: TrackerDataStore
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {

        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")

        let primarySortDescriptor = NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title), ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: #keyPath(TrackerCoreData.name), ascending: true)

        fetchRequest.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    init(_ dataStore: TrackerDataStore) {
        self.context = dataStore.managedObjectContext
        self.dataStore = dataStore
    }
}

// MARK: - DataProviderProtocol
extension TrackerStore: TrackerStoreProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func sectionTitle(for section: Int) -> String {
        let currentSection = fetchedResultsController.sections?[section]
        return currentSection?.name ?? ""
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        let tracker = trackerCoreData.toTracker()
        return tracker
    }

    func saveTracker(_ tracker: Tracker, titleCategory: String) throws {
         dataStore.saveTracker(tracker, titleCategory: titleCategory)
    }

    func deleteTracker(at indexPath: IndexPath) throws {
//        let record = fetchedResultsController.object(at: indexPath)
//        try? dataStore.delete(record)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerStoreUpdate(
            insertedIndexes: insertedIndexes!,
            deletedIndexes: deletedIndexes!
        )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}

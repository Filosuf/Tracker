//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Filosuf on 09.03.2023.
//

import Foundation
import CoreData

struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

protocol TrackerCategoryStoreProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func sectionTitle(for section: Int) -> String
    func object(at: IndexPath) -> TrackerCategory?
    func addCategory(_ category: TrackerCategory) throws
    func deleteCategory(at indexPath: IndexPath) throws
}

// MARK: - TrackerCategoryStore
final class TrackerCategoryStore: NSObject {

    enum DataProviderError: Error {
        case failedToInitializeContext
    }

    weak var delegate: TrackerCategoryStoreDelegate?

    private let context: NSManagedObjectContext
    private let dataStore: TrackerCategoryDataStore
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {

        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    init(_ dataStore: TrackerCategoryDataStore) {
        self.context = dataStore.managedObjectContext
        self.dataStore = dataStore
    }
}

// MARK: - DataProviderProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
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

    func object(at indexPath: IndexPath) -> TrackerCategory? {
        let trackerCategoryCoreData = fetchedResultsController.object(at: indexPath)
        guard let title = trackerCategoryCoreData.title else { return nil }
        let trackers =  trackerCategoryCoreData.trackersSorted.map { $0.toTracker() }
        return TrackerCategory(title: title, trackers: trackers)
    }

    func addCategory(_ category: TrackerCategory) throws {
         dataStore.add(category)
    }

    func deleteCategory(at indexPath: IndexPath) throws {
//        let record = fetchedResultsController.object(at: indexPath)
//        try? dataStore.delete(record)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerCategoryStoreUpdate(
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

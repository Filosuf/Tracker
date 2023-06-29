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
    func object(at: IndexPath) -> TrackerCategory?
    func isDuplicateOfCategory(with title: String) -> Bool
    func updateCategoryTitle(previous: String, new: String)
    func addCategory(_ category: TrackerCategory)
    func deleteCategory(at indexPath: IndexPath)
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
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

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
        super.init()
        self.createPinnedCategory()
    }

    private func createPinnedCategory() {
        guard isDuplicateOfCategory(with: "pinned") else { return }
        let category = TrackerCategory(title: "pinned", trackers: [])
        addCategory(category)
    }
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func object(at indexPath: IndexPath) -> TrackerCategory? {
        let trackerCategoryCoreData = fetchedResultsController.object(at: indexPath)
        guard let title = trackerCategoryCoreData.title else { return nil }
        let trackers =  trackerCategoryCoreData.trackersSorted.map { $0.toTracker() }
        return TrackerCategory(title: title, trackers: trackers)
    }

    func isDuplicateOfCategory(with title: String) -> Bool {
        dataStore.isDuplicateOfCategory(with: title)
    }

    func addCategory(_ category: TrackerCategory) {
         dataStore.add(category)
    }

    func updateCategoryTitle(previous: String, new: String) {
        dataStore.updateCategoryTitle(previous: previous, new: new)
    }

    func deleteCategory(at indexPath: IndexPath)  {
        let category = fetchedResultsController.object(at: indexPath)
        dataStore.delete(category)
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

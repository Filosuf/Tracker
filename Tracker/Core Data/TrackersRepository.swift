//
//  TrackersRepository.swift
//  Tracker
//
//  Created by Filosuf on 09.03.2023.
//

import CoreData
import UIKit

final class TrackersRepository {
    // MARK: - Properties
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    private var context: NSManagedObjectContext { persistentContainer.viewContext }

    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
               let nserror = error as NSError
                assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - NotepadDataStore
extension TrackersRepository: TrackerCategoryDataStore {
    var managedObjectContext: NSManagedObjectContext {
        context
    }

    func add(_ trackerCategory: TrackerCategory) {

        let newCategory  = fetchCategory(title: trackerCategory.title, context: context) ?? TrackerCategoryCoreData(context: context)
        newCategory.title = trackerCategory.title
        saveContext()
    }

//    func delete(_ record: NSManagedObject) throws {
//        try performSync { context in
//            Result {
//                context.delete(record)
//                try context.save()
//            }
//        }
//    }
    func isDuplicateOfCategory(with title: String) -> Bool {
        let duplicate = fetchCategory(title: title, context: context)
        return duplicate != nil
    }

    func updateCategoryTitle(previous: String, new: String) {
        let category = fetchCategory(title: previous, context: context)
        category?.title = new
        saveContext()
    }

    private func fetchCategory(title: String, context: NSManagedObjectContext) -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), title)
        return (try? context.fetch(request))?.first
    }
}

extension TrackersRepository: TrackerDataStore {

    func saveTracker(_ tracker: Tracker, titleCategory: String) {
        let newTracker  = fetchTracker(trackerId: tracker.id, context: context) ?? TrackerCoreData(context: context)
        let trackerCategory = fetchCategory(title: titleCategory, context: context)

        newTracker.id = tracker.id
        newTracker.name = tracker.name
        newTracker.color = tracker.color.hexValue
        newTracker.emoji = tracker.emoji
        newTracker.schedule = tracker.schedule.map { $0.rawValue }.joined()
        newTracker.category = trackerCategory

        saveContext()
    }
    
    func deleteTracker(_ tracker: Tracker) {

    }

    private func fetchTracker(trackerId: String, context: NSManagedObjectContext) -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerId)
        return (try? context.fetch(request))?.first
    }

}

extension TrackersRepository: TrackerRecordDataStore {

    func addRecord(trackerId: String, date: Date) {
        let newRecord  = TrackerRecordCoreData(context: context)
        let tracker  = fetchTracker(trackerId: trackerId, context: context)

        newRecord.id = trackerId
        newRecord.date = date
        newRecord.tracker = tracker

        saveContext()
    }

    func deleteRecord(trackerId: String, date: Date) {
        if let record = fetchRecord(trackerId: trackerId, date: date, context: context) {
            context.delete(record)
            saveContext()
        }
    }

    func fetchRecords(trackerId: String) -> [TrackerRecordCoreData]? {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerId)
        let recordsCoreData = try? context.fetch(request)
        return recordsCoreData

    }

    private func fetchRecord(trackerId: String, date: Date, context: NSManagedObjectContext) -> TrackerRecordCoreData? {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ && %K == %@", trackerId, #keyPath(TrackerRecordCoreData.date), date as NSDate)
        return (try? context.fetch(request))?.first
    }
}

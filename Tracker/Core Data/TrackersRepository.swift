//
//  TrackersRepository.swift
//  Tracker
//
//  Created by Filosuf on 09.03.2023.
//

import Foundation
import CoreData

final class TrackersRepository {
    // MARK: - Properties
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
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
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
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
        let result = try? context.fetch(request)
        return (try? context.fetch(request))?.first
    }
}

extension TrackersRepository: TrackerDataStore {

    func saveTracker(_ tracker: Tracker, titleCategory: String) {
        let newTracker  = fetchTracker(tracker: tracker, context: context) ?? TrackerCoreData(context: context)
        let trackerCategory = fetchCategory(title: titleCategory, context: context)

        newTracker.name = tracker.name
        newTracker.color = tracker.color
        newTracker.emoji = tracker.emoji
        newTracker.schedule = tracker.schedule.map { $0.rawValue }.joined()
        newTracker.category = trackerCategory

        saveContext()
    }
    
    func deleteTracker(_ tracker: Tracker) {

    }

    private func fetchTracker(tracker: Tracker, context: NSManagedObjectContext) -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id)
        return (try? context.fetch(request))?.first
    }
}

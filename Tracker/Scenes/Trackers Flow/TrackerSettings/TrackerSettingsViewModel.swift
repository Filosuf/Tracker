//
//  TrackerSettingsViewModel.swift
//  Tracker
//
//  Created by Filosuf on 01.04.2023.
//

import UIKit

struct TrackerForView: Equatable {
    let id: String
    let name: String?
    let color: UIColor?
    let emoji: String?
    let schedule: String
}

enum TrackerStyle {
    case newHabit
    case newEvent
    case editHabit
    case editEvent
}

protocol TrackerSettingsViewModel {
    //Constants property
    var maxNameLength: Int { get }
    var emojis: [String] { get }
    var colorsName: [String] { get }

    var trackerModel: TrackerForView? { get }
    var trackerStyle: TrackerStyle { get }
    var trackerCategory: TrackerCategory? { get }
    var warningText: String? { get }

    var recordsString: String? { get }

    //Update
    func updateTrackerName(name: String)
    func updateEmoji(_ emoji: String)
    func updateColor(_ color: UIColor?)
    func updateCategory(_ category: TrackerCategory)
    func updateSchedule(_ schedule: [DayOfWeek])

    func addRecord()
    func removeRecord()

    //Hadle
    func categoryCellTapHandle()
    func scheduleCellTapHandle()
    func cancelButtonHandle()
    func saveButtonHandle()

    //binding
    var saveButtonStateDidChange: ((Bool) -> Void)? { get set }
    var warningTextDidChange: (() -> Void)? { get set }
    var recordsStringDidChange: (() -> Void)? { get set }
}

final class TrackerSettingsViewModelImpl: TrackerSettingsViewModel {
    // MARK: - Properties
    private let coordinator: SettingsFlowCoordinator
    private let trackerStore: TrackerStoreProtocol
    private var indexPathEditTracker: IndexPath?

//    var tracker: Tracker?
    private(set) var trackerModel: TrackerForView? 
    private(set) var trackerCategory: TrackerCategory?
    private(set) var trackerStyle: TrackerStyle
    private var saveButtonIsEnable = false {
        didSet {
            saveButtonStateDidChange?(saveButtonIsEnable)
        }
    }
    private(set) var warningText: String? {
        didSet {
            warningTextDidChange?()
        }
    }

    private(set) var recordsString: String? {
        didSet {
            recordsStringDidChange?()
        }
    }

    var maxNameLength: Int { Constants.maxNameLength }
    var emojis: [String] { Constants.emojis }
    var colorsName: [String] { Constants.colorsName }

    var saveButtonStateDidChange: ((Bool) -> Void)?
    var warningTextDidChange: (() -> Void)?
    var recordsStringDidChange: (() -> Void)?

    //Оперируем с отдельными свойствами tracker, для удобства, когда tracker = nil
    private var tempTrackerId: String?
    private var tempTrackerName: String?
    private var tempTrackerColor: UIColor?
    private var tempTrackerEmoji: String?
    private var tempTrackerSchedule = [DayOfWeek]()

    enum Constants {
        static let maxNameLength = 38
        static let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
        static let colorsName = ["color-1", "color-2", "color-3", "color-4", "color-5", "color-6", "color-7", "color-8", "color-9",
                                 "color-10", "color-11", "color-12", "color-13", "color-14", "color-15", "color-16", "color-17", "color-18"
        ]
    }

    // MARK: - Initialiser
    init(coordinator: SettingsFlowCoordinator, trackerStore: TrackerStoreProtocol, trackerStyle: TrackerStyle, indexPathEditTracker: IndexPath?) {
        self.coordinator = coordinator
        self.trackerStore = trackerStore
        self.trackerStyle = trackerStyle
        self.indexPathEditTracker = indexPathEditTracker
        initialization()
    }

    // MARK: - Methods
    private func initialization() {
        guard let indexPath = indexPathEditTracker else { return }
        let tracker = trackerStore.object(at: indexPath)
        trackerCategory = trackerStore.category(at: indexPath)
        updateTrackerProperties(tracker)
        updateTrackerModel()
        updateSaveButtonState()
        updateRecords()
    }

    private func updateTrackerProperties(_ tracker: Tracker?) {
        guard let tracker = tracker else { return }

        tempTrackerId = tracker.id
        tempTrackerName = tracker.name
        tempTrackerColor = tracker.color
        tempTrackerEmoji = tracker.emoji
        tempTrackerSchedule = tracker.schedule
    }

    private func updateRecords() {
        guard let indexPath = indexPathEditTracker else { return }
        let numberOfRecords = trackerStore.records(at: indexPath).count
        if trackerStyle == .editHabit {
            recordsString = String(format: "day".localized, numberOfRecords)
        } else {
            recordsString = String(format: "time".localized, numberOfRecords)
        }
        
    }

    func updateTrackerName(name: String) {
        tempTrackerName = name
        warningText = name.count <= Constants.maxNameLength ? nil : "Ограничение \(Constants.maxNameLength) символов"
        updateSaveButtonState()
        updateTrackerModel()
    }

    func updateEmoji(_ emoji: String) {
        tempTrackerEmoji = emoji
        updateSaveButtonState()
        updateTrackerModel()
    }

    func updateColor(_ color: UIColor?) {
        tempTrackerColor = color
        updateSaveButtonState()
        updateTrackerModel()
    }

    func updateSchedule(_ schedule: [DayOfWeek]) {
        tempTrackerSchedule = schedule
        updateSaveButtonState()
        updateTrackerModel()
    }

    func updateCategory(_ category: TrackerCategory) {
        trackerCategory = category
        updateSaveButtonState()
        updateTrackerModel()
    }

    func addRecord() {
        print("addRecord")
    }

    func removeRecord() {
        print("removeRecord")
    }

    func cancelButtonHandle() {
        coordinator.dismissSettings()
    }

    func saveButtonHandle() {
        addOrUpdateTracker()
        coordinator.dismissSettings()
    }

    func categoryCellTapHandle() {
        coordinator.showCategories(current: trackerCategory, delegate: self)
    }

    func scheduleCellTapHandle() {
        coordinator.showSchedule(schedule: tempTrackerSchedule, delegate: self)
    }

    private func addOrUpdateTracker() {
        guard let trackerCategory = trackerCategory,
        let name = tempTrackerName,
        let color = tempTrackerColor,
        let emoji = tempTrackerEmoji else  { return }

        let id = tempTrackerId ?? UUID().uuidString.lowercased()
        let newOrEditTracker = Tracker(id: id, name: name, color: color, emoji: emoji, schedule: tempTrackerSchedule)

        trackerStore.saveTracker(newOrEditTracker, titleCategory: trackerCategory.title)
    }

    private func updateSaveButtonState() {
        guard let name = tempTrackerName else { return }
        if !name.isEmpty,
           name.count <= Constants.maxNameLength,
           trackerCategory != nil,
           tempTrackerEmoji != nil,
           tempTrackerColor != nil {
            saveButtonIsEnable = true
        }
        else {
            saveButtonIsEnable = false
        }
    }

    private func updateTrackerModel() {
        trackerModel = TrackerForView(
            id: tempTrackerId ?? UUID().uuidString.lowercased(),
            name: tempTrackerName,
            color: tempTrackerColor,
            emoji: tempTrackerEmoji,
            schedule: scheduleToString(tempTrackerSchedule)
        )
    }

    private func scheduleToString(_ schedule: [DayOfWeek]) -> String {
        guard schedule.count != DayOfWeek.allCases.count else { return "Каждый день" }

        let scheduleSorted = schedule.sorted()
        let scheduleShortName = scheduleSorted.map { $0.shortName }.joined(separator: ", ")
        return scheduleShortName
    }
}

// MARK: - ScheduleViewControllerProtocol
extension TrackerSettingsViewModelImpl: ScheduleViewControllerProtocol {
    func scheduleDidUpdate(schedule: [DayOfWeek]) {
        updateSchedule(schedule)
    }
}
// MARK: - CategoriesViewControllerProtocol
extension TrackerSettingsViewModelImpl: CategoriesViewControllerProtocol {
    func categoriesDidUpdate(selected category: TrackerCategory) {
        updateCategory(category)
    }
}

//
//  ScheduleViewModel.swift
//  Tracker
//
//  Created by Filosuf on 03.04.2023.
//

import Foundation

struct ScheduleCellModel {
    let title: String
    let isSetCheckmark: Bool
}

protocol ScheduleViewModel {

    var numberOfRowsInSection: Int { get }
    func fetchViewModelForCell(with indexPath: IndexPath) -> ScheduleCellModel

    func updateSchedule(cell indexPath: IndexPath, status isOn: Bool)
    func finishEditing()
}

final class ScheduleViewModelImpl: ScheduleViewModel {
    // MARK: - Properties
    private var coordinator: SettingsFlowCoordinator
    private var delegate: ScheduleViewControllerProtocol
    private var week = DayOfWeek.allCases
    private var schedule = [DayOfWeek]()

    var numberOfRowsInSection: Int { week.count }

    // MARK: - Initialiser
    init(coordinator: SettingsFlowCoordinator, schedule: [DayOfWeek], delegate: ScheduleViewControllerProtocol) {
        self.coordinator = coordinator
        self.schedule = schedule
        self.delegate = delegate
    }

    // MARK: - Methods
    func fetchViewModelForCell(with indexPath: IndexPath) -> ScheduleCellModel {
        let day = week[indexPath.row]
        let isOn = schedule.firstIndex(of: day) != nil
        let cellViewModel = ScheduleCellModel(title: day.rawValue, isSetCheckmark: isOn)
        return cellViewModel
    }

    func updateSchedule(cell indexPath: IndexPath, status isOn: Bool) {
        let day = self.week[indexPath.row]
        if isOn {
            schedule.append(day)
        } else {
            schedule.removeAll(where: { $0 == day })
        }
    }

    func finishEditing() {
        delegate.scheduleDidUpdate(schedule: schedule)
        coordinator.pop()
    }
}

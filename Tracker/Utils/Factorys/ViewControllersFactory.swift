//
//  ViewControllersFactory.swift
//  Tracker
//
//  Created by Filosuf on 30.01.2023.
//

import UIKit

final class ViewControllersFactory {

    func makeTrackersViewController(coordinator: TrackersFlowCoordinator) -> TrackersViewController {
        let viewController = TrackersViewController(coordinator: coordinator)
        return viewController
    }

    func makeNewTrackerViewController(coordinator: SettingsFlowCoordinator) -> NewTrackerViewController {
        let viewController = NewTrackerViewController(coordinator: coordinator)
        return viewController
    }

    func makeTrackerSettingsViewController(coordinator: SettingsFlowCoordinator, tracker: Tracker?, isRegular: Bool) -> TrackerSettingsViewController {
        let trackerSettingsStyle = getTrackerSettingsStyle(tracker: tracker, isRegular: isRegular)
        let viewController = TrackerSettingsViewController(coordinator: coordinator, tracker: tracker, trackerStyle: trackerSettingsStyle)
        return viewController
    }

    func makeCategoriesViewController(coordinator: SettingsFlowCoordinator,
                                      current category: TrackerCategory?,
                                      in categories: [TrackerCategory],
                                      delegate: CategoriesViewControllerProtocol
    ) -> CategoriesViewController {
        let viewController = CategoriesViewController(coordinator: coordinator, current: category, in: categories, delegate: delegate)
        return viewController
    }

    func makeScheduleViewController(coordinator: SettingsFlowCoordinator, schedule: [DayOfWeek], delegate: ScheduleViewControllerProtocol) -> ScheduleViewController {
        let viewController = ScheduleViewController(coordinator: coordinator, schedule: schedule, delegate: delegate)
        return viewController
    }

    func makeCategorySettingsViewController(coordinator: SettingsFlowCoordinator,
                                            category: TrackerCategory?,
                                            delegate: CategorySettingsViewControllerProtocol
    ) -> CategorySettingsViewController {
        let viewController = CategorySettingsViewController(coordinator: coordinator, category: category, delegate: delegate)
        return viewController
    }

    func makeStatsViewController() -> StatsViewController {
        let viewController = StatsViewController()
        return viewController
    }

    private func getTrackerSettingsStyle(tracker: Tracker?, isRegular: Bool) -> TrackerStyle {
        if let tracker = tracker {
            if isRegular {
                return .editHabit(tracker: tracker)
            } else {
                return .editEvent(tracker: tracker)
            }
        } else {
            if isRegular {
                return .newHabit
            } else {
                return .newEvent
            }
        }
    }
}

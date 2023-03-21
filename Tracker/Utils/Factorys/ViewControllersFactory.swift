//
//  ViewControllersFactory.swift
//  Tracker
//
//  Created by Filosuf on 30.01.2023.
//

import UIKit

final class ViewControllersFactory {

    func makeTrackersViewController(coordinator: TrackersFlowCoordinator, trackerStore: TrackerStoreProtocol, recordStore: TrackerRecordStoreProtocol) -> TrackersViewController {
        let viewController = TrackersViewController(coordinator: coordinator, trackerStore: trackerStore, recordStore: recordStore)
        return viewController
    }

    func makeNewTrackerViewController(coordinator: SettingsFlowCoordinator) -> NewTrackerViewController {
        let viewController = NewTrackerViewController(coordinator: coordinator)
        return viewController
    }

    func makeTrackerSettingsViewController(coordinator: SettingsFlowCoordinator,
                                           trackerStyle: TrackerStyle,
                                           trackerStore: TrackerStoreProtocol
    ) -> TrackerSettingsViewController {
        let viewController = TrackerSettingsViewController(coordinator: coordinator, trackerStyle: trackerStyle, trackerStore: trackerStore)
        return viewController
    }

    func makeCategoriesViewController(coordinator: SettingsFlowCoordinator,
                                      trackerCategoryStore: TrackerCategoryStoreProtocol,
                                      current category: TrackerCategory?,
                                      delegate: CategoriesViewControllerProtocol
    ) -> CategoriesViewController {
        let viewController = CategoriesViewController(coordinator: coordinator, trackerCategoryStore: trackerCategoryStore, current: category, delegate: delegate)
        return viewController
    }

    func makeScheduleViewController(coordinator: SettingsFlowCoordinator, schedule: [DayOfWeek], delegate: ScheduleViewControllerProtocol) -> ScheduleViewController {
        let viewController = ScheduleViewController(coordinator: coordinator, schedule: schedule, delegate: delegate)
        return viewController
    }

    func makeCategorySettingsViewController(coordinator: SettingsFlowCoordinator,
                                            trackerCategoryStore: TrackerCategoryStoreProtocol,
                                            indexPathEditCategory: IndexPath?
    ) -> CategorySettingsViewController {
        let viewController = CategorySettingsViewController(coordinator: coordinator, trackerCategoryStore: trackerCategoryStore, indexPathEditCategory: indexPathEditCategory)
        return viewController
    }

    func makeStatsViewController() -> StatsViewController {
        let viewController = StatsViewController()
        return viewController
    }
}

//
//  ViewControllersFactory.swift
//  Tracker
//
//  Created by Filosuf on 30.01.2023.
//

import UIKit

final class ViewControllersFactory {

    func makeTrackersViewController(coordinator: TrackersFlowCoordinator, trackerStore: TrackerStoreProtocol) -> TrackersViewController {
        let viewController = TrackersViewController(coordinator: coordinator, trackerStore: trackerStore)
        return viewController
    }

    func makeNewTrackerViewController(coordinator: SettingsFlowCoordinator, categories: [TrackerCategory], rootViewController: TrackerSettingsViewControllerProtocol) -> NewTrackerViewController {
        let viewController = NewTrackerViewController(coordinator: coordinator, categories: categories, rootViewController: rootViewController)
        return viewController
    }

    func makeTrackerSettingsViewController(coordinator: SettingsFlowCoordinator,
                                           trackerStyle: TrackerStyle,
                                           delegate: TrackerSettingsViewControllerProtocol
    ) -> TrackerSettingsViewController {
        let viewController = TrackerSettingsViewController(coordinator: coordinator, trackerStyle: trackerStyle, delegate: delegate)
        return viewController
    }

    func makeCategoriesViewController(coordinator: SettingsFlowCoordinator,
                                      trackerCategoryStore: TrackerCategoryStoreProtocol,
                                      current category: TrackerCategory?,
                                      in categories: [TrackerCategory],
                                      delegate: CategoriesViewControllerProtocol
    ) -> CategoriesViewController {
        let viewController = CategoriesViewController(coordinator: coordinator, trackerCategoryStore: trackerCategoryStore, current: category, in: categories, delegate: delegate)
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

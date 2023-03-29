//
//  ViewControllersFactory.swift
//  Tracker
//
//  Created by Filosuf on 30.01.2023.
//

import UIKit

final class ViewControllersFactory {

    //MARK: - Trackers Flow
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
        let viewModel = CategoriesViewModel(categoryStore: trackerCategoryStore, coordinator: coordinator, current: category, delegate: delegate)
        let viewController = CategoriesViewController(viewModel: viewModel)
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
        let viewModel = CategorySettingsViewModel(coordinator: coordinator, trackerCategoryStore: trackerCategoryStore, indexPathEditCategory: indexPathEditCategory)
        let viewController = CategorySettingsViewController(viewModel: viewModel)
        return viewController
    }

    //MARK: - Stats Flow
    func makeStatsViewController() -> StatsViewController {
        let viewController = StatsViewController()
        return viewController
    }

    //MARK: - Onboarding
    func makeOnboarding(settingsStorage: SettingsStorageProtocol, coordinator: MainCoordinator) -> OnboardingPageViewController {
        let pageFirst = makeOnboardingFirst()
        let pageSecond = makeOnboardingSecond()
        let pages = [pageFirst, pageSecond]

        let onboarding = OnboardingPageViewController(pages: pages, settingsStorage: settingsStorage, coordinator: coordinator)
        return onboarding
    }

    func makeOnboardingFirst() -> OnboardingViewController {
        let background = UIImage(named: "onboardingFirst")
        let title = "Отслеживайте только то, что хотите"
        let vc = OnboardingViewController(backgroundImage: background, title: title)
        return vc
    }

    func makeOnboardingSecond() -> OnboardingViewController {
        let background = UIImage(named: "onboardingSecond")
        let title = "Даже если это не литры воды или йога"
        let vc = OnboardingViewController(backgroundImage: background, title: title)
        return vc
    }
}

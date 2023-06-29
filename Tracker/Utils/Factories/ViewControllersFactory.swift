//
//  ViewControllersFactory.swift
//  Tracker
//
//  Created by Filosuf on 30.01.2023.
//

import UIKit

final class ViewControllersFactory {

    //MARK: - Trackers Flow
    func makeTrackersViewController(coordinator: TrackersFlowCoordinator, trackerStore: TrackerStoreProtocol, recordStore: TrackerRecordStoreProtocol, statsStorage: SettingsStorageProtocol) -> TrackersViewController {
        let viewController = TrackersViewController(coordinator: coordinator, trackerStore: trackerStore, recordStore: recordStore, statsStorage: statsStorage)
        return viewController
    }

    func makeNewTrackerViewController(coordinator: SettingsFlowCoordinator) -> NewTrackerViewController {
        let viewController = NewTrackerViewController(coordinator: coordinator)
        return viewController
    }

    func makeTrackerSettingsViewController(coordinator: SettingsFlowCoordinator,
                                           trackerStore: TrackerStoreProtocol,
                                           trackerStyle: TrackerStyle,
                                           indexPathEditTracker: IndexPath?
    ) -> TrackerSettingsViewController {
        let viewModel = TrackerSettingsViewModelImpl(coordinator: coordinator, trackerStore: trackerStore, trackerStyle: trackerStyle, indexPathEditTracker: indexPathEditTracker)
        let viewController = TrackerSettingsViewController(viewModel: viewModel)
        return viewController
    }

    func makeCategoriesViewController(coordinator: SettingsFlowCoordinator,
                                      trackerCategoryStore: TrackerCategoryStore,
                                      current category: TrackerCategory?,
                                      delegate: CategoriesViewControllerProtocol
    ) -> CategoriesViewController {
        let viewModel = CategoriesViewModel(categoryStore: trackerCategoryStore, coordinator: coordinator, current: category, delegate: delegate)
        let viewController = CategoriesViewController(viewModel: viewModel)
        trackerCategoryStore.delegate = viewModel
        return viewController
    }

    func makeScheduleViewController(coordinator: SettingsFlowCoordinator, schedule: [DayOfWeek], delegate: ScheduleViewControllerProtocol) -> ScheduleViewController {
        let viewModel = ScheduleViewModelImpl(coordinator: coordinator, schedule: schedule, delegate: delegate)
        let viewController = ScheduleViewController(viewModel: viewModel)
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
    func makeStatsViewController(statsStorage: SettingsStorageProtocol) -> StatsViewController {
        let viewController = StatsViewController(statsStorage: statsStorage)
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
        let title = "onboardingPageFirstTitle".localized
        let vc = OnboardingViewController(backgroundImage: background, title: title)
        return vc
    }

    func makeOnboardingSecond() -> OnboardingViewController {
        let background = UIImage(named: "onboardingSecond")
        let title = "onboardingPageSecondTitle".localized
        let vc = OnboardingViewController(backgroundImage: background, title: title)
        return vc
    }
}

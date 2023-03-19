//
//  SettingsFlowCoordinator.swift
//  Tracker
//
//  Created by Filosuf on 03.02.2023.
//

import UIKit

final class SettingsFlowCoordinator {

    // MARK: - Properties
    private let controllersFactory: ViewControllersFactory
    private let navCon: UINavigationController
    private let dataStoreFactory: DataStoreFactory
    
    //MARK: - Initialiser
    init(navCon: UINavigationController, controllersFactory: ViewControllersFactory, dataStoreFactory: DataStoreFactory) {
        self.controllersFactory = controllersFactory
        self.navCon = navCon
        self.dataStoreFactory = dataStoreFactory
    }

    // MARK: - Methods
    func showTrackerSettings(trackerStyle: TrackerStyle, delegate: TrackerSettingsViewControllerProtocol) {
        let vc = controllersFactory.makeTrackerSettingsViewController(coordinator: self, trackerStyle: trackerStyle, delegate: delegate)
        navCon.pushViewController(vc, animated: true)
    }

    func showCategories(current category: TrackerCategory?,
                        in categories: [TrackerCategory],
                        delegate: CategoriesViewControllerProtocol) {
        let trackerCategoryStore = dataStoreFactory.makeTrackerCategoryStore()
        let vc = controllersFactory.makeCategoriesViewController(coordinator: self, trackerCategoryStore: trackerCategoryStore, current: category, in: categories, delegate: delegate)
        navCon.pushViewController(vc, animated: true)
    }

    func showSchedule(schedule: [DayOfWeek], delegate: ScheduleViewControllerProtocol) {
        let vc = controllersFactory.makeScheduleViewController(coordinator: self, schedule: schedule, delegate: delegate)
        navCon.pushViewController(vc, animated: true)
    }

    func showCategorySettings(indexPathEditCategory: IndexPath?) {
        let trackerCategoryStore = dataStoreFactory.makeTrackerCategoryStore()
        let vc = controllersFactory.makeCategorySettingsViewController(coordinator: self, trackerCategoryStore: trackerCategoryStore, indexPathEditCategory: indexPathEditCategory)
        navCon.pushViewController(vc, animated: true)
    }

    func dismissSettings() {
        navCon.dismiss(animated: true)
    }

    func pop() {
        navCon.popViewController(animated: true)
    }
}

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
    func showTrackerSettings(trackerStyle: TrackerStyle, indexPathEditTracker: IndexPath? = nil) {
        let trackerStore = dataStoreFactory.makeTrackerStore()
        let vc = controllersFactory.makeTrackerSettingsViewController(coordinator: self, trackerStore: trackerStore, trackerStyle: trackerStyle, indexPathEditTracker: indexPathEditTracker)
        navCon.pushViewController(vc, animated: true)
    }

    func showCategories(current category: TrackerCategory?,
                        delegate: CategoriesViewControllerProtocol) {
        let trackerCategoryStore = dataStoreFactory.makeTrackerCategoryStore()
        let vc = controllersFactory.makeCategoriesViewController(coordinator: self, trackerCategoryStore: trackerCategoryStore, current: category, delegate: delegate)
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

    func showDeleteAlert(action: @escaping () -> Void) {
        let alert = UIAlertController(
            title: nil,
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet)

        alert.view.accessibilityIdentifier = "error_alert"

        let action = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            action()
        }

        let cancel = UIAlertAction(title: "Отменить", style: .cancel)

        alert.addAction(action)
        alert.addAction(cancel)

        navCon.present(alert, animated: true, completion: nil)
    }

    func dismissSettings() {
        navCon.dismiss(animated: true)
    }

    func pop() {
        navCon.popViewController(animated: true)
    }
}

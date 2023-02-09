//
//  SettingsFlowCoordinator.swift
//  Tracker
//
//  Created by Filosuf on 03.02.2023.
//

import UIKit

final class SettingsFlowCoordinator {

    private let controllersFactory: ViewControllersFactory
    let navCon: UINavigationController

    //MARK: - Initialiser
    init(navCon: UINavigationController, controllersFactory: ViewControllersFactory) {
        self.controllersFactory = controllersFactory
        self.navCon = navCon
    }

    func showTrackerSettings(trackerStyle: TrackerStyle, delegate: TrackerSettingsViewControllerProtocol) {
        let vc = controllersFactory.makeTrackerSettingsViewController(coordinator: self, trackerStyle: trackerStyle, delegate: delegate)
        navCon.pushViewController(vc, animated: true)
    }

    func showCategories(current category: TrackerCategory?,
                        in categories: [TrackerCategory],
                        delegate: CategoriesViewControllerProtocol) {
        let vc = controllersFactory.makeCategoriesViewController(coordinator: self, current: category, in: categories, delegate: delegate)
        navCon.pushViewController(vc, animated: true)
    }

    func showSchedule(schedule: [DayOfWeek], delegate: ScheduleViewControllerProtocol) {
        let vc = controllersFactory.makeScheduleViewController(coordinator: self, schedule: schedule, delegate: delegate)
        navCon.pushViewController(vc, animated: true)
    }

    func showCategorySettings(category: TrackerCategory?,
                        delegate: CategorySettingsViewControllerProtocol) {
        let vc = controllersFactory.makeCategorySettingsViewController(coordinator: self, category: category, delegate: delegate)
        navCon.pushViewController(vc, animated: true)
    }

    func dismissSettings() {
        navCon.dismiss(animated: true)
    }

    func pop() {
        navCon.popViewController(animated: true)
    }
}

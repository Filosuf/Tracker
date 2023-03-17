//
//  TrackersFlowCoordinator.swift
//  Tracker
//
//  Created by Filosuf on 30.01.2023.
//

import UIKit

final class TrackersFlowCoordinator {

    // MARK: - Properties
    private let navCon: UINavigationController
    private let controllersFactory: ViewControllersFactory
    private let dataStoreFactory: DataStoreFactory

    //MARK: - Initialiser
    init(navCon: UINavigationController, controllersFactory: ViewControllersFactory, dataStoreFactory: DataStoreFactory) {
        self.navCon = navCon
        self.controllersFactory = controllersFactory
        self.dataStoreFactory = dataStoreFactory
    }

    // MARK: - Methods
    func showNewTracker(rootViewController: TrackerSettingsViewControllerProtocol, categories: [TrackerCategory]) {
        let navigationVC = UINavigationController()
        let coordinator = SettingsFlowCoordinator(navCon: navigationVC, controllersFactory: controllersFactory)
        let vc = controllersFactory.makeNewTrackerViewController(coordinator: coordinator, categories: categories, rootViewController: rootViewController)
        navigationVC.pushViewController(vc, animated: true)
        navCon.present(navigationVC, animated: true)
    }
}

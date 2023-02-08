//
//  TrackersFlowCoordinator.swift
//  Tracker
//
//  Created by Filosuf on 30.01.2023.
//

import UIKit

final class TrackersFlowCoordinator {

    private let controllersFactory: ViewControllersFactory
    let navCon: UINavigationController

    //MARK: - Initialiser
    init(navCon: UINavigationController, controllersFactory: ViewControllersFactory) {
        self.controllersFactory = controllersFactory
        self.navCon = navCon
    }

    func showNewTracker() {
        let navigationVC = UINavigationController()
        let coordinator = SettingsFlowCoordinator(navCon: navigationVC, controllersFactory: controllersFactory)
        let vc = controllersFactory.makeNewTrackerViewController(coordinator: coordinator)
        navigationVC.pushViewController(vc, animated: true)
        navCon.present(navigationVC, animated: true)
    }

//    func showTrackerSettings(isRegular: Bool, navigationVC: UINavigationController) {
//        let vc = controllersFactory.makeTrackerSettingsViewController(coordinator: self, isRegular: isRegular)
//        navigationVC.pushViewController(vc, animated: true)
//    }
}

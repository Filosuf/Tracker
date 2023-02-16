//
//  MainCoordinator.swift
//  Tracker
//
//  Created by Filosuf on 30.01.2023.
//

import UIKit

protocol MainCoordinator {
    func startApplication() -> UIViewController
}

final class MainCoordinatorImp: MainCoordinator {

    private let controllersFactory = ViewControllersFactory()
    private var userEmail: String?

    func startApplication() -> UIViewController {
        return getTabBarController()
    }

    //MARK: - Metods
    private func getTabBarController() -> UIViewController {
        let tabBarVC = UITabBarController()
        tabBarVC.tabBar.backgroundColor = .white

        let viewControllers = TabBarPage.allCases.map { getNavController(page: $0) }
        tabBarVC.setViewControllers(viewControllers, animated: true)
        return tabBarVC
    }

    private func getNavController(page: TabBarPage) -> UINavigationController {
        let navigationVC = UINavigationController()
        navigationVC.tabBarItem.image = page.image
        navigationVC.tabBarItem.title = page.pageTitle

        switch page {
        case .trackers:
            let trackerChildCoordinator = TrackersFlowCoordinator(navCon: navigationVC, controllersFactory: controllersFactory)
            let trackersVC = controllersFactory.makeTrackersViewController(coordinator: trackerChildCoordinator)
            navigationVC.navigationBar.prefersLargeTitles = true
            navigationVC.pushViewController(trackersVC, animated: true)
        case .stats:
            let statsVC = controllersFactory.makeStatsViewController()
            navigationVC.navigationBar.prefersLargeTitles = true
            navigationVC.pushViewController(statsVC, animated: true)
        }

        return navigationVC
    }
}

//
//  MainCoordinator.swift
//  Tracker
//
//  Created by Filosuf on 30.01.2023.
//

import UIKit

enum TabBarPage {
    case trackers
    case stats

    var pageTitle: String {
        switch self {
        case .trackers:
            return "Трекеры"
        case .stats:
            return "Статистика"
        }
    }

    var image: UIImage? {
        switch self {
        case .trackers:
            return UIImage(systemName: "record.circle.fill")
        case .stats:
            return UIImage(systemName: "hare.fill")
        }
    }
}

protocol MainCoordinator {
    func startApplication() -> UIViewController
}

final class MainCoordinatorImp: MainCoordinator {

    private let controllersFactory = ViewControllersFactory()
    private var userEmail: String?

    // проверка авторизован ли юзер
    // показать либо экран авторизации, либо новостную ленту
    func startApplication() -> UIViewController {
        return getTabBarController()
    }

    //MARK: - Metods
    private func getTabBarController() -> UIViewController {
        let tabBarVC = UITabBarController()
        tabBarVC.tabBar.backgroundColor = .white
        let pages: [TabBarPage] = [.trackers, .stats]

        tabBarVC.setViewControllers(pages.map { getNavController(page: $0) }, animated: true)
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

//
//  MainCoordinator.swift
//  Tracker
//
//  Created by Filosuf on 30.01.2023.
//

import UIKit

protocol MainCoordinator {
    func startApplication(skipOnboarding: Bool) -> UIViewController
    func switchToTabBarController()
}

final class MainCoordinatorImp: MainCoordinator {

    // MARK: - Properties
    private let controllersFactory: ViewControllersFactory
    private let dataStoreFactory: DataStoreFactory
    private let settingsStorage: SettingsStorageProtocol

    // MARK: - LifeCycle
    init(controllersFactory: ViewControllersFactory, dataStoreFactory: DataStoreFactory, settingsStorage: SettingsStorageProtocol) {
        self.controllersFactory = controllersFactory
        self.dataStoreFactory = dataStoreFactory
        self.settingsStorage = settingsStorage
    }

    // MARK: - Methods
    func startApplication(skipOnboarding: Bool) -> UIViewController {
        if skipOnboarding {
            return getTabBarController()
        } else {
            return controllersFactory.makeOnboarding(settingsStorage: SettingsStorage(), coordinator: self)
        }
    }

    func switchToTabBarController() {
        // Получаем экземпляр `Window` приложения
        guard let window = UIApplication.shared.windows.first else { assertionFailure("Invalid Configuration"); return }
        window.rootViewController = getTabBarController()
    }

    //MARK: - Private methods
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
            let trackerChildCoordinator = TrackersFlowCoordinator(navCon: navigationVC, controllersFactory: controllersFactory, dataStoreFactory: dataStoreFactory)
            let trackerStore = dataStoreFactory.makeTrackerStore()
            let _ = dataStoreFactory.makeTrackerCategoryStore()
            let recordStore = dataStoreFactory.makeTrackerRecordsStore()
            let trackersVC = controllersFactory.makeTrackersViewController(coordinator: trackerChildCoordinator, trackerStore: trackerStore, recordStore: recordStore, statsStorage: settingsStorage)
            // TODO: - не нравится место назначение делегата, поискать другие варианты
            trackerStore.delegate = trackersVC
            navigationVC.navigationBar.prefersLargeTitles = true
            navigationVC.pushViewController(trackersVC, animated: true)
        case .stats:
            let statsVC = controllersFactory.makeStatsViewController(statsStorage: settingsStorage)
            navigationVC.navigationBar.prefersLargeTitles = true
            navigationVC.pushViewController(statsVC, animated: true)
        }

        return navigationVC
    }
}

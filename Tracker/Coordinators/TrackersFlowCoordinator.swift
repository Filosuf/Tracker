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
//    private let newNavCon = UINavigationController()
//    private lazy var settingsFlowCoordinator = SettingsFlowCoordinator(navCon: newNavCon, controllersFactory: controllersFactory, dataStoreFactory: dataStoreFactory)

    //MARK: - Initialiser
    init(navCon: UINavigationController, controllersFactory: ViewControllersFactory, dataStoreFactory: DataStoreFactory) {
        self.navCon = navCon
        self.controllersFactory = controllersFactory
        self.dataStoreFactory = dataStoreFactory
    }

    // MARK: - Methods
    func showNewTracker() {
        let newNavCon = UINavigationController()
        let settingsFlowCoordinator = SettingsFlowCoordinator(navCon: newNavCon, controllersFactory: controllersFactory, dataStoreFactory: dataStoreFactory)
        let vc = controllersFactory.makeNewTrackerViewController(coordinator: settingsFlowCoordinator)
        newNavCon.pushViewController(vc, animated: true)
        navCon.present(newNavCon, animated: true)
    }

    func showTrackerSettings(trackerStyle: TrackerStyle, indexPathEditTracker: IndexPath? = nil) {
        let newNavCon = UINavigationController()
        let settingsFlowCoordinator = SettingsFlowCoordinator(navCon: newNavCon, controllersFactory: controllersFactory, dataStoreFactory: dataStoreFactory)
        let trackerStore = dataStoreFactory.makeTrackerStore()
        let vc = controllersFactory.makeTrackerSettingsViewController(coordinator: settingsFlowCoordinator, trackerStore: trackerStore, trackerStyle: trackerStyle, indexPathEditTracker: indexPathEditTracker)
        newNavCon.pushViewController(vc, animated: true)
        navCon.present(newNavCon, animated: true)
    }

    func showDeleteAlert(action: @escaping () -> Void) {
        let alert = UIAlertController(
            title: nil,
            message: "Уверены, что хотите удалить трекер?",
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
}

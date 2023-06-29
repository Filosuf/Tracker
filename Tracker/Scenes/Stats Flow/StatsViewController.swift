//
//  StatsViewController.swift
//  Tracker
//
//  Created by Filosuf on 30.01.2023.
//

import UIKit

final class StatsViewController: UIViewController {
    // MARK: - Properties
    private let statsStorage: SettingsStorageProtocol
    private let emptyStatsImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "emptyStats")
        return image
    }()

    private let emptyStatsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "Анализировать пока нечего"
        return label
    }()

    private let completedTrackersView = StatsSubview()

    // MARK: - Initialiser
    init(statsStorage: SettingsStorageProtocol) {
        self.statsStorage = statsStorage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Статистика"
        layout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }

    // MARK: - Methods
    private func setupView() {
        let numberOfCompletedTrackers = statsStorage.numberOfCompletedTrackers
        let empty = numberOfCompletedTrackers == 0
        emptyStatsImage.isHidden = !empty
        emptyStatsLabel.isHidden = !empty
        completedTrackersView.isHidden = empty
        completedTrackersView.update(fact: "\(numberOfCompletedTrackers)", description: "Трекеров завершено")
    }

    private func layout() {
        [emptyStatsImage,
         emptyStatsLabel,
         completedTrackersView
        ].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }

        NSLayoutConstraint.activate([
            emptyStatsImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStatsImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStatsImage.heightAnchor.constraint(equalToConstant: 80),
            emptyStatsImage.widthAnchor.constraint(equalToConstant: 80),

            emptyStatsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStatsLabel.topAnchor.constraint(equalTo: emptyStatsImage.bottomAnchor, constant: 8),

            completedTrackersView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            completedTrackersView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            completedTrackersView.heightAnchor.constraint(equalToConstant: 90),
            completedTrackersView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
    }

}

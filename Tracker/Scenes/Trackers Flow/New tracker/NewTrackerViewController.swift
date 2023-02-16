//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Filosuf on 31.01.2023.
//

import UIKit

final class NewTrackerViewController: UIViewController {
    // MARK: - Properties
    private let coordinator: SettingsFlowCoordinator
    private let rootViewController: TrackerSettingsViewControllerProtocol
    private let categories: [TrackerCategory]

    private let newHabitButton = CustomButton(title: "Привычка")
    private let newEventButton = CustomButton(title: "Нерегулярное событие")

    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()

    // MARK: - Initialiser
    init(coordinator: SettingsFlowCoordinator, categories: [TrackerCategory], rootViewController: TrackerSettingsViewControllerProtocol) {
        self.coordinator = coordinator
        self.categories = categories
        self.rootViewController = rootViewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Создание трекера"
        view.backgroundColor = .white
        layout()
        setupAction()
    }

    // MARK: - Methods
    private func setupAction() {
        newHabitButton.tapAction = { [weak self] in
            guard let self = self else { return }
            self.coordinator.showTrackerSettings(trackerStyle: .newHabit(categories: self.categories), delegate: self.rootViewController)
        }
        newEventButton.tapAction = { [weak self] in
            guard let self = self else { return }
            self.coordinator.showTrackerSettings(trackerStyle: .newEvent(categories: self.categories), delegate: self.rootViewController)
        }
    }

    private func layout() {

        [newHabitButton,
         newEventButton
        ].forEach { verticalStackView.addArrangedSubview($0)}

        view.addSubview(verticalStackView)

        NSLayoutConstraint.activate([
            newHabitButton.heightAnchor.constraint(equalToConstant: 60),
            newEventButton.heightAnchor.constraint(equalTo: newHabitButton.heightAnchor),

            verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

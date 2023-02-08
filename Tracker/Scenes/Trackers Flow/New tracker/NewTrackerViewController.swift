//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Filosuf on 31.01.2023.
//

import UIKit

final class NewTrackerViewController: UIViewController {
    // MARK: - Properties
    var coordinator: SettingsFlowCoordinator

    private let newHabitButton = CustomButton(title: "Привычка")
    private let newEventButton = CustomButton(title: "Нерегулярное событие")

//    private let newHabitButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("Привычка", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        button.backgroundColor = .Custom.black
//        button.layer.cornerRadius = 16
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(newHabit), for: .touchUpInside)
//        return button
//    }()
//
//    private let newEventButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("Нерегулярное событие", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        button.backgroundColor = .Custom.black
//        button.layer.cornerRadius = 16
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(newEvent), for: .touchUpInside)
//        return button
//    }()

    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()

    // MARK: - Initialiser
    init(coordinator: SettingsFlowCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Создание трекера"
        view.backgroundColor = .white
        taps()
    }

    // MARK: - Methods
//    @objc private func newHabit() {
//        coordinator.showTrackerSettings(tracker: nil, isRegular: true)
//    }
//
//    @objc private func newEvent() {
//        coordinator.showTrackerSettings(tracker: nil, isRegular: false)
//    }
    private func taps() {
        newHabitButton.tapAction = { [weak self] in
            self?.coordinator.showTrackerSettings(tracker: nil, isRegular: true)
        }
        newEventButton.tapAction = { [weak self] in
            self?.coordinator.showTrackerSettings(tracker: nil, isRegular: false)
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

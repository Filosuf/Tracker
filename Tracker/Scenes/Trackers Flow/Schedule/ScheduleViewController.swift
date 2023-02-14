//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Filosuf on 06.02.2023.
//

import UIKit

protocol ScheduleViewControllerProtocol {
    func scheduleDidUpdate(schedule: [DayOfWeek])
}

final class ScheduleViewController: UIViewController {
    // MARK: - Properties
    private var coordinator: SettingsFlowCoordinator
    private var delegate: ScheduleViewControllerProtocol
    private var week = DayOfWeek.getWeek()
    private var schedule = [DayOfWeek]()

    private let okButton = CustomButton(title: "Готово")

    private lazy var weekTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.identifier)
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Initialiser
    init(coordinator: SettingsFlowCoordinator, schedule: [DayOfWeek], delegate: ScheduleViewControllerProtocol) {
        self.coordinator = coordinator
        self.schedule = schedule
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        title = "Расписание"
        taps()
        layout()
    }
    
    // MARK: - Methods
    private func updateSchedule(for day: DayOfWeek, with isOn: Bool) {
        if isOn {
            schedule.append(day)
        } else {
            schedule.removeAll(where: {$0 == day})
        }
    }

    private func taps() {
        okButton.tapAction = { [weak self] in
            guard let self = self else { return }

            self.delegate.scheduleDidUpdate(schedule: self.schedule)
            self.coordinator.pop()
        }
    }

    private func layout() {
        [weekTableView,
        okButton
        ].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            weekTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            weekTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weekTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weekTableView.heightAnchor.constraint(equalToConstant: 75 * 7),

            okButton.heightAnchor.constraint(equalToConstant: 60),
            okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        week.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.identifier, for: indexPath) as! ScheduleTableViewCell
        let day = week[indexPath.row]
        let isOn = schedule.firstIndex(of: day) != nil
        cell.configure(title: day.rawValue, isOn: isOn)
        cell.buttonAction = { [weak self] isOn in
            guard let self = self else { return }

            let dayChange = self.week[indexPath.row]
            self.updateSchedule(for: dayChange, with: isOn)
        }
        return cell
    }

}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

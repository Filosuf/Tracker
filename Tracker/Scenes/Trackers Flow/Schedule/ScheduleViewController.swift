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
    private var viewModel: ScheduleViewModel

    private let okButton = CustomButton(title: "done".localized)

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
    init(viewModel: ScheduleViewModel) {
        self.viewModel = viewModel
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
        title = "scheduleTitle".localized
        setupAction()
        layout()
    }
    
    // MARK: - Methods
    private func setupAction() {
        okButton.tapAction = { [weak self] in
            self?.viewModel.finishEditing()
        }
    }

    private func layout() {
        [weekTableView,
        okButton
        ].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            weekTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            weekTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            weekTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
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
        viewModel.numberOfRowsInSection
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.identifier, for: indexPath) as! ScheduleTableViewCell

        let cellModel = viewModel.fetchViewModelForCell(with: indexPath)
        cell.configure(cellModel: cellModel)
        cell.buttonAction = { [weak self] isOn in
            self?.viewModel.updateSchedule(cell: indexPath, status: isOn)
        }
        return cell
    }

}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

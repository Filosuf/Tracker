//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Filosuf on 27.06.2023.
//

import UIKit
enum Filter: String, CaseIterable {
    case all = "Все трекеры"
    case today = "Трекеры на сегодня"
    case completed = "Завершенные"
    case notCompleted = "Не завершенные"
}

protocol FiltersViewControllerDelegate {
    func filterDidUpdate()
}

final class FiltersViewController: UIViewController {
    // MARK: - Properties
    private let settingsStorage: SettingsStorageProtocol
    private let filters = Filter.allCases
    private var currentFilter: Filter?
    private let delegate: FiltersViewControllerDelegate

    private lazy var filtersTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(CategoriesTableViewCell.self, forCellReuseIdentifier: CategoriesTableViewCell.identifier)
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    // MARK: - Initialiser
    init(settingsStorage: SettingsStorageProtocol, delegate: FiltersViewControllerDelegate) {
        self.settingsStorage = settingsStorage
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
        view.backgroundColor = .systemBackground
        title = "filters".localized
        layout()
        currentFilter = settingsStorage.filter
    }

    // MARK: - Methods
    private func layout() {
        [filtersTableView].forEach { view.addSubview($0)}

        NSLayoutConstraint.activate([
            filtersTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
}

// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesTableViewCell.identifier, for: indexPath) as! CategoriesTableViewCell
        var isSetCheckmark = false
        if let currentFilter = currentFilter, let index = filters.firstIndex(of: currentFilter) {
            isSetCheckmark = index == indexPath.row
        }
        cell.configure(title: filters[indexPath.row].rawValue, isSetCheckmark: isSetCheckmark)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentFilter = filters[indexPath.row]
        settingsStorage.saveFilter(filters[indexPath.row])
        delegate.filterDidUpdate()
        dismiss(animated: true, completion: nil)
        print("Filter")
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let numberOfCategories = 4
        let isLastCell = indexPath.row == numberOfCategories - 1
        let isFirstCell = indexPath.row == 0

        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        cell.selectionStyle = .none
        if isFirstCell {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastCell {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset.left = cell.bounds.size.width
        } else {
            cell.layer.cornerRadius = 0
        }
    }
}

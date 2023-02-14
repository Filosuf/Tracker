//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Filosuf on 06.02.2023.
//

import UIKit

protocol CategoriesViewControllerProtocol {
    func categoriesDidUpdate(selected category: TrackerCategory, in categories: [TrackerCategory])
}

final class CategoriesViewController: UIViewController {
    // MARK: - Properties
    private let coordinator: SettingsFlowCoordinator
    private var categories = [TrackerCategory]()
    private let delegate: CategoriesViewControllerProtocol

    private var currentCategory: TrackerCategory?

    private let infoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "star")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = """
                Привычки и события можно
                объединить по смыслу
                """
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var categoriesTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(CategoriesTableViewCell.self, forCellReuseIdentifier: CategoriesTableViewCell.identifier)
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let addCategoryButton = CustomButton(title: "Добавить категорию")
    
    // MARK: - Initialiser
    init(coordinator: SettingsFlowCoordinator, current category: TrackerCategory?, in categories: [TrackerCategory], delegate: CategoriesViewControllerProtocol) {
        self.coordinator = coordinator
        currentCategory = category
        self.categories = categories
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        taps()
        layout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        categoriesTableView.reloadData()
    }
    
    // MARK: - Methods
    private func taps() {
        addCategoryButton.tapAction = { [weak self] in
            guard let self = self else { return }
            self.coordinator.showCategorySettings(edit: nil, in: self.categories, delegate: self)
        }
    }

    private func setupView() {
        title = "Категория"
        if categories.isEmpty {
            categoriesTableView.isHidden = true
            infoLabel.isHidden = false
            infoImage.isHidden = false
        } else {
            categoriesTableView.isHidden = false
            infoLabel.isHidden = true
            infoImage.isHidden = true
        }
    }

    private func layout() {
        [infoImage,
         infoLabel,
         categoriesTableView,
         addCategoryButton
        ].forEach { view.addSubview($0)}

        NSLayoutConstraint.activate([
            infoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoImage.heightAnchor.constraint(equalToConstant: 100),
            infoImage.widthAnchor.constraint(equalToConstant: 100),

            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.topAnchor.constraint(equalTo: infoImage.bottomAnchor, constant: 16),

            categoriesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),

            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesTableViewCell.identifier, for: indexPath) as! CategoriesTableViewCell
        let category = categories[indexPath.row]
        let isSetCheckmark = category == currentCategory
        cell.configure(title: category.title, isSetCheckmark: isSetCheckmark)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentCategory = categories[indexPath.row]
        tableView.reloadData()
        delegate.categoriesDidUpdate(selected: categories[indexPath.row], in: categories)
        coordinator.pop()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isLastCell = indexPath.row == categories.count - 1
        let isFirstCell = indexPath.row == 0
        let isOnlyOneCell = categories.count == 1

        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        if isOnlyOneCell {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
        } else if isFirstCell {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastCell {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
}

//MARK: - CategorySettingsViewControllerProtocol
extension CategoriesViewController: CategorySettingsViewControllerProtocol {
    func categorySettingsDidUpdated(categories: [TrackerCategory]) {
        self.categories = categories
    }
}


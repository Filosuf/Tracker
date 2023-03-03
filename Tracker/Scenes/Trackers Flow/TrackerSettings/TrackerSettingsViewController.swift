//
//  HabitSettingsViewController.swift
//  Tracker
//
//  Created by Filosuf on 30.01.2023.
//

import UIKit

enum TrackerStyle {
    case newHabit(categories: [TrackerCategory])
    case newEvent(categories: [TrackerCategory])
    case editHabit(tracker: Tracker, currentCategory: TrackerCategory, categories: [TrackerCategory])
    case editEvent(tracker: Tracker, currentCategory: TrackerCategory, categories: [TrackerCategory])
}

enum SettingsType: String {
    case category = "Категория"
    case schedule = "Расписание"
}

protocol TrackerSettingsViewControllerProtocol {
    func categoriesDidUpdate(with categories: [TrackerCategory])
}

final class TrackerSettingsViewController: UIViewController {
    // MARK: - Properties
    private var coordinator: SettingsFlowCoordinator
    private var delegate: TrackerSettingsViewControllerProtocol
    private var tracker: Tracker?
    private var currentCategory: TrackerCategory?
    private var categories = [TrackerCategory]()
    private let trackerStyle: TrackerStyle
    private var nameTextFieldTop: CGFloat = 0
    private var settingsTableViewHeight: CGFloat { CGFloat(nameSettingsArray.count * 75 - 1) }
    private var settingsTableViewTopConstraint: NSLayoutConstraint?
    private var nameSettingsArray = [SettingsType]()
    private let emojiCollectionDataSource = EmojiCollectionViewDataSource(emojis: Constants.emojis)
    private let colorCollectionDataSource = ColorCollectionViewDataSource(colors: Constants.colorsName)

    //Оперируем с отдельными свойствами tracker, для удобства, когда tracker = nil
    private var tempTrackerId: String?
    private var tempTrackerName: String?
    private var tempTrackerColor: UIColor?
    private var tempTrackerEmoji: String?
    private var tempTrackerSchedule = [DayOfWeek]()

    private enum Constants {
        static let maxNameLength = 38
        static let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
        static let colorsName = ["color-1", "color-2", "color-3", "color-4", "color-5", "color-6", "color-7", "color-8", "color-9",
                                 "color-10", "color-11", "color-12", "color-13", "color-14", "color-15", "color-16", "color-17", "color-18"
        ]
    }

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    private let cancelButton = CancelButton(title: "Отменить")
    private let saveButton = CustomButton(title: "Save")

    private let numberOfDayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .Custom.text
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "5 days"
        return label
    }()

    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение \(Constants.maxNameLength) символов"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .Custom.red
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .Custom.text
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.backgroundColor = .Custom.actionBackground
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.leftViewMode = UITextField.ViewMode.always
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.leftView = UIView(frame:CGRect(x:0, y:0, width:10, height:textField.frame.height))
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var settingsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let emojiCollectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .Custom.text
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Emoji"
        return label
    }()

    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        collectionView.dataSource = emojiCollectionDataSource
        collectionView.delegate = emojiCollectionDataSource
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private let colorCollectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .Custom.text
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Цвет"
        return label
    }()

    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        collectionView.dataSource = colorCollectionDataSource
        collectionView.delegate = colorCollectionDataSource
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    // MARK: - Initialiser
    init(coordinator: SettingsFlowCoordinator, trackerStyle: TrackerStyle, delegate: TrackerSettingsViewControllerProtocol) {
        self.coordinator = coordinator
        self.trackerStyle = trackerStyle
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
        saveButton.isEnabled = false
        updateProperties(with: trackerStyle)
        updateTrackerProperties(tracker: tracker)
        setupNavBar()
        layout()
        setupAction()
        hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingsTableView.reloadData()
    }

    // MARK: - Methods
    ///update properties for edit tracker
    private func updateProperties(with style: TrackerStyle) {
        switch trackerStyle {
        case .newHabit(let categories):
            self.categories = categories
        case .newEvent(let categories):
            self.categories = categories
        case .editHabit(let tracker, let currentCategory, let categories):
            self.tracker = tracker
            self.currentCategory = currentCategory
            self.categories = categories
        case .editEvent(let tracker, let currentCategory, let categories):
            self.tracker = tracker
            self.currentCategory = currentCategory
            self.categories = categories
        }
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        tempTrackerName = textField.text
        showWarningLabelIfNeeded()
        updateSaveButton()
    }

    private func showWarningLabelIfNeeded() {
        guard let name = nameTextField.text else { return }
        if name.count <= Constants.maxNameLength {
            if !warningLabel.isHidden {
                settingsTableViewTopConstraint?.constant = 24
                view.setNeedsLayout()
            }
            warningLabel.isHidden = true
        } else {
            if warningLabel.isHidden {
                settingsTableViewTopConstraint?.constant = 62
                warningLabel.isHidden = false
                view.setNeedsLayout()
            }
        }
    }

    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    private func updateTrackerProperties(tracker: Tracker?) {
        guard let tracker = tracker else { return }

        tempTrackerId = tracker.id
        tempTrackerName = tracker.name
        tempTrackerColor = tracker.color
        tempTrackerEmoji = tracker.emoji
        tempTrackerSchedule = tracker.schedule
    }

    private func setupNavBar() {
        navigationItem.hidesBackButton = true
        switch trackerStyle {
        case .newHabit:
            title = "Новая привычка"
        case .newEvent:
            title = "Новое нерегулярное событие"
        case .editHabit:
            title = "Редактирование привычки"
        case .editEvent:
            title = "Редактирование нерегулярного события"
        }
    }

    private func setupView() {
        switch trackerStyle {
        case .newHabit:
            numberOfDayLabel.isHidden = true
            nameTextFieldTop = 0
            nameSettingsArray = [.category, .schedule]
            saveButton.updateButton(title: "Создать", backgroundColor: .gray)
        case .newEvent:
            numberOfDayLabel.isHidden = true
            nameTextFieldTop = 0
            nameSettingsArray = [.category]
            saveButton.updateButton(title: "Создать", backgroundColor: .gray)
        case .editHabit:
            title = "Редактирование привычки"
        case .editEvent:
            title = "Редактирование нерегулярного события"
        }
    }

    private func setupAction() {
        cancelButton.tapAction = { [weak self] in
            self?.coordinator.dismissSettings()
        }
        saveButton.tapAction = { [weak self] in
            self?.onSaveAction()
        }
        emojiCollectionDataSource.tapAction = { [weak self] emoji in
            self?.tempTrackerEmoji = emoji
            self?.updateSaveButton()
        }
        colorCollectionDataSource.tapAction = { [weak self] colorName in
            self?.tempTrackerColor = UIColor(named: colorName)
            self?.updateSaveButton()
        }
    }

    private func onSaveAction() {
        addOrUpdateTracker()
        delegate.categoriesDidUpdate(with: self.categories)
        coordinator.dismissSettings()
    }

    private func addOrUpdateTracker() {
        guard let currentCategory = currentCategory else  { return }
        let unchangeableTrackers = currentCategory.trackers.filter { $0 != tracker }
        let id = tempTrackerId ?? UUID().uuidString.lowercased()
        let name = tempTrackerName ?? "default name"
        let color = tempTrackerColor ?? .systemPink //debug default value
        let emoji = tempTrackerEmoji ?? "🍏"
        let newOrEditTracker = Tracker(id: id, name: name, color: color, emoji: emoji, schedule: tempTrackerSchedule)

        let categoryTitle = currentCategory.title
        categories.removeAll(where: { $0 == currentCategory })
        var trackers = unchangeableTrackers + [newOrEditTracker]
        trackers.sort(by: { $0.name < $1.name })
        let updatedCategory = TrackerCategory(title: categoryTitle, trackers: trackers)
        categories.append(updatedCategory)
    }

    private func scheduleToString(schedule: [DayOfWeek]) -> String {
        guard schedule.count != DayOfWeek.allCases.count else { return "Каждый день" }

        let scheduleSorted = schedule.sorted()
        let scheduleShortName = scheduleSorted.map { $0.shortName }.joined(separator: ", ")
        return scheduleShortName
    }

    private func updateSaveButton() {
        guard let name = nameTextField.text else { return }
        if !name.isEmpty,
           name.count <= Constants.maxNameLength,
           currentCategory != nil,
           tempTrackerEmoji != nil,
           tempTrackerColor != nil {
            saveButton.isEnabled = true
            saveButton.updateBackground(backgroundColor: .Custom.text)
        }
        else {
            saveButton.isEnabled = false
            saveButton.updateBackground(backgroundColor: .Custom.gray)
        }
    }


    private func layout() {
        setupView()

        [numberOfDayLabel,
         nameTextField,
         warningLabel,
         settingsTableView,
         emojiCollectionLabel,
         emojiCollectionView,
         colorCollectionLabel,
         colorCollectionView
        ].forEach { contentView.addSubview($0) }

        scrollView.addSubview(contentView)

        [scrollView,
         cancelButton,
         saveButton
        ].forEach { view.addSubview($0) }

        settingsTableViewTopConstraint = settingsTableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24)
        settingsTableViewTopConstraint?.isActive = true

        NSLayoutConstraint.activate([
            numberOfDayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            numberOfDayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),

            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo: numberOfDayLabel.bottomAnchor, constant: nameTextFieldTop),

            warningLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            warningLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            warningLabel.heightAnchor.constraint(equalToConstant: 22),

            settingsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            settingsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            settingsTableView.heightAnchor.constraint(equalToConstant: settingsTableViewHeight),

            emojiCollectionLabel.topAnchor.constraint(equalTo: settingsTableView.bottomAnchor, constant: 16),
            emojiCollectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            emojiCollectionView.topAnchor.constraint(equalTo: emojiCollectionLabel.bottomAnchor, constant: 16),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),

            colorCollectionLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorCollectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            colorCollectionView.topAnchor.constraint(equalTo: colorCollectionLabel.bottomAnchor, constant: 16),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            saveButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            saveButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor)

        ])
    }
}

// MARK: - UITableViewDataSource
extension TrackerSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nameSettingsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "identifier")
        cell.textLabel?.text = nameSettingsArray[indexPath.row].rawValue
        var detailText = ""
        if nameSettingsArray[indexPath.row] == .category {
            detailText = currentCategory?.title ?? ""
        } else {
            detailText = scheduleToString(schedule: tempTrackerSchedule)
        }
        cell.detailTextLabel?.text = detailText
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .Custom.actionBackground
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UITableViewDelegate
extension TrackerSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let nameSettings = nameSettingsArray[indexPath.row]
        switch nameSettings {
        case .category:
            coordinator.showCategories(current: currentCategory, in: categories, delegate: self)
        case .schedule:
            coordinator.showSchedule(schedule: tempTrackerSchedule, delegate: self)
        }
    }
}

//MARK: - UITextFieldDelegate
extension TrackerSettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// MARK: - ScheduleViewControllerProtocol
extension TrackerSettingsViewController: ScheduleViewControllerProtocol {
    func scheduleDidUpdate(schedule: [DayOfWeek]) {
        tempTrackerSchedule = schedule
        updateSaveButton()
    }
}
// MARK: - CategoriesViewControllerProtocol
extension TrackerSettingsViewController: CategoriesViewControllerProtocol {
    func categoriesDidUpdate(selected category: TrackerCategory, in categories: [TrackerCategory]) {
        currentCategory = category
        self.categories = categories
        updateSaveButton()
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerSettingsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Constants.emojis.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as! EmojiCollectionViewCell
        let emoji = Constants.emojis[indexPath.row]
        cell.setupCell(emoji: emoji)
        return cell
    }


    //MARK: - UICollectionViewDelegateFlowLayout
    private var sideInset: CGFloat { return 16}

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
}

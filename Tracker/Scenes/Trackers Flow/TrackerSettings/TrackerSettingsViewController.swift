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
    private var nameSettingsArray = [SettingsType]()

    //Оперируем с отдельными свойствами tracker, для удобства, когда tracker = nil
    private var tempTrackerId: Double?
    private var tempTrackerName: String?
    private var tempTrackerColor: UIColor?
    private var tempTrackerEmoji: String?
    private var tempTrackerSchedule = [DayOfWeek]()

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

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .Custom.text
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.backgroundColor = .Custom.actionBackground
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.leftViewMode = UITextField.ViewMode.always
//        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.leftView = UIView(frame:CGRect(x:0, y:0, width:10, height:textField.frame.height))
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var settingsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .Custom.actionBackground
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
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
        taps()
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
        updateSaveButton()
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

    private func taps() {
        cancelButton.tapAction = { [weak self] in
            self?.coordinator.dismissSettings()
        }
        saveButton.tapAction = { [weak self] in
            guard let self = self else { return }
            self.addOrUpdateTracker()
            self.delegate.categoriesDidUpdate(with: self.categories)
            self.coordinator.dismissSettings()
        }
    }

    private func addOrUpdateTracker() {
        guard let currentCategory = currentCategory else  { return }
        let unchangeableTrackers = currentCategory.trackers.filter{$0 != tracker}
        let id = tempTrackerId ?? Date().timeIntervalSince1970
        let name = tempTrackerName ?? "default name"
        let color = tempTrackerColor ?? .systemPink //debug default value
        let emoji = tempTrackerEmoji ?? "🍏"
        let newOrEditTracker = Tracker(id: id, name: name, color: color, emoji: emoji, schedule: tempTrackerSchedule)

        let categoryTitle = currentCategory.title
        categories.removeAll(where: {$0 == currentCategory})
        var trackers = unchangeableTrackers + [newOrEditTracker]
        trackers.sort(by: {$0.name < $1.name})
        let updatedCategory = TrackerCategory(title: categoryTitle, trackers: trackers)
        categories.append(updatedCategory)
    }

    private func scheduleToString(schedule: [DayOfWeek]) -> String {
        guard schedule.count != 7 else { return "Каждый день" }

        var result = ""
        let scheduleSorted = schedule.sorted()
        for (index, day) in scheduleSorted.enumerated() {
            result += day.shortName
            if index < schedule.count - 1 {
                result += ", "
            }
        }
        return result
    }

    private func updateSaveButton() {
        guard let name = nameTextField.text else { return }
        if name != "",
           Array(name).count < 39,
           currentCategory != nil {
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
         settingsTableView,
         cancelButton,
         saveButton
        ].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            numberOfDayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            numberOfDayLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),

            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo: numberOfDayLabel.bottomAnchor, constant: nameTextFieldTop),

            settingsTableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            settingsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            settingsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            settingsTableView.heightAnchor.constraint(equalToConstant: 240),

            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:  -16),

            saveButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            saveButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)

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
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
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

//(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // create cell
//    // ...
//    if ([self.checkedPath isEqual:indexPath])
//    {
//        outCell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
//    else
//    {
//        outCell.accessoryType = UITableViewCellAccessoryNone;
//    }
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    self.checkedPath = indexPath;
//    [self.tableView reloadData];
//}

//
//  HabitSettingsViewController.swift
//  Tracker
//
//  Created by Filosuf on 30.01.2023.
//

import UIKit

enum SettingsType: String {
    case category
    case schedule
}

final class TrackerSettingsViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: TrackerSettingsViewModel

    private var nameTextFieldTop: CGFloat = 0
    private var settingsTableViewHeight: CGFloat { CGFloat(nameSettingsArray.count * 75 - 1) }
    private var settingsTableViewTopConstraint: NSLayoutConstraint?
    private var nameSettingsArray = [SettingsType]()
    private lazy var emojiCollectionDataSource = EmojiCollectionViewDataSource(emojis: viewModel.emojis)
    private lazy var colorCollectionDataSource = ColorCollectionViewDataSource(colors: viewModel.colorsName)

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
        label.textColor = .Custom.blackDay
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let plusButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .Custom.orange
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 34 / 2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addRecord), for: .touchUpInside)
        return button
    }()

    private let minusButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .Custom.orange
        button.setTitle("-", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 34 / 2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(removeRecord), for: .touchUpInside)
        return button
    }()

    private let warningLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .Custom.red
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .Custom.blackDay
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
        label.textColor = .Custom.blackDay
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "emoji".localized
        return label
    }()

    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = emojiCollectionDataSource
        collectionView.delegate = emojiCollectionDataSource
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private let colorCollectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .Custom.blackDay
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "color".localized
        return label
    }()

    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = colorCollectionDataSource
        collectionView.delegate = colorCollectionDataSource
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    // MARK: - Initialiser
    init(viewModel: TrackerSettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        layout()
        setupAction()
        hideKeyboardWhenTappedAround()
        initialization()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingsTableView.reloadData()
    }

    // MARK: - Methods
    private func initialization() {
        if let tracker = viewModel.trackerModel {
            numberOfDayLabel.text = viewModel.recordsString

            nameTextField.text = tracker.name
            var colorIndex: Int?
            for (index, colorName) in viewModel.colorsName.enumerated() {
                if UIColor(named: colorName)?.hexValue == tracker.color?.hexValue {
                    colorIndex = index
                }
            }
            let colorIndexPath = IndexPath(item: colorIndex ?? 0, section: 0)
            colorCollectionView.selectItem(at: colorIndexPath, animated: true, scrollPosition: .centeredVertically)

            var emojiIndex: Int?
            for (index, emoji) in viewModel.emojis.enumerated() {
                if emoji == tracker.emoji {
                    emojiIndex = index
                }
            }
            let emojiIndexPath = IndexPath(item: emojiIndex ?? 0, section: 0)
            emojiCollectionView.selectItem(at: emojiIndexPath, animated: true, scrollPosition: .centeredVertically)
        }
    }

    private func bind() {
        viewModel.saveButtonStateDidChange = { [weak self] isEnable in
            self?.updateSaveButtonState(isEnable: isEnable)
        }
        viewModel.warningTextDidChange = { [weak self] in
            self?.showWarningLabelIfNeeded(text: self?.viewModel.warningText)
        }
        viewModel.recordsStringDidChange = { [weak self] in
            self?.numberOfDayLabel.text = self?.viewModel.recordsString
        }
    }

    @objc private func addRecord() {
        viewModel.addRecord()
    }

    @objc private func removeRecord() {
        viewModel.removeRecord()
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let name = textField.text else { return }
        viewModel.updateTrackerName(name: name)
    }

    private func updateSaveButtonState(isEnable: Bool) {
        saveButton.updateBackground(backgroundColor: isEnable ? .Custom.blackDay : .Custom.gray)
        saveButton.isEnabled = isEnable
    }

    private func showWarningLabelIfNeeded(text: String?) {
        warningLabel.text = text
        warningLabel.isHidden = text == nil
        let newConstraint: CGFloat = text == nil ? 24 : 62
        if settingsTableViewTopConstraint?.constant != newConstraint {
            settingsTableViewTopConstraint?.constant = newConstraint
            view.setNeedsLayout()
        }
    }

    private func setupView() {
        switch viewModel.trackerStyle {
        case .newHabit:
            title = "newHabit".localized
            numberOfDayLabel.isHidden = true
            minusButton.isHidden = true
            plusButton.isHidden = true
            nameTextFieldTop = 0
            nameSettingsArray = [.category, .schedule]
            saveButton.updateButton(title: "create".localized, backgroundColor: .Custom.gray)
            saveButton.isEnabled = false
        case .newEvent:
            title = "newEvent".localized
            numberOfDayLabel.isHidden = true
            minusButton.isHidden = true
            plusButton.isHidden = true
            nameTextFieldTop = 0
            nameSettingsArray = [.category]
            saveButton.updateButton(title: "create".localized, backgroundColor: .Custom.gray)
            saveButton.isEnabled = false
        case .editHabit:
            title = "editHabit".localized
            numberOfDayLabel.isHidden = false
            minusButton.isHidden = false
            plusButton.isHidden = false
            nameTextFieldTop = 102
            nameSettingsArray = [.category, .schedule]
            saveButton.updateButton(title: "save".localized, backgroundColor: .Custom.blackDay)
            saveButton.isEnabled = true
        case .editEvent:
            title = "editEvent".localized
            numberOfDayLabel.isHidden = false
            minusButton.isHidden = false
            plusButton.isHidden = false
            nameTextFieldTop = 102
            nameSettingsArray = [.category]
            saveButton.updateButton(title: "save".localized, backgroundColor: .Custom.blackDay)
            saveButton.isEnabled = true
        }
    }

    private func setupAction() {
        cancelButton.tapAction = { [weak self] in
            self?.viewModel.cancelButtonHandle()
        }
        saveButton.tapAction = { [weak self] in
            self?.viewModel.saveButtonHandle()
        }
        emojiCollectionDataSource.tapAction = { [weak self] emoji in
            self?.viewModel.updateEmoji(emoji)
        }
        colorCollectionDataSource.tapAction = { [weak self] colorName in
            let color = UIColor(named: colorName)
            self?.viewModel.updateColor(color)
        }
    }

    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func layout() {
        setupView()

        [plusButton,
         numberOfDayLabel,
         minusButton,
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
            minusButton.centerYAnchor.constraint(equalTo: numberOfDayLabel.centerYAnchor),
            minusButton.trailingAnchor.constraint(equalTo: numberOfDayLabel.leadingAnchor, constant: -24),
            minusButton.heightAnchor.constraint(equalToConstant: 34),
            minusButton.widthAnchor.constraint(equalToConstant: 34),

            plusButton.centerYAnchor.constraint(equalTo: numberOfDayLabel.centerYAnchor),
            plusButton.leadingAnchor.constraint(equalTo: numberOfDayLabel.trailingAnchor, constant: 24),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34),

            numberOfDayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            numberOfDayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),

            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: nameTextFieldTop),

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
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16)

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
        cell.textLabel?.text = nameSettingsArray[indexPath.row].rawValue.localized
        var detailText: String?
        if nameSettingsArray[indexPath.row] == .category {
            detailText = viewModel.trackerCategory?.title
        } else {
            detailText = viewModel.trackerModel?.schedule
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
            viewModel.categoryCellTapHandle()
        case .schedule:
            viewModel.scheduleCellTapHandle()
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



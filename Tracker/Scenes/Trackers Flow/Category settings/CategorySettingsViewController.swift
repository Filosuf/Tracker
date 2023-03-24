//
//  CategorySettingsViewController.swift
//  Tracker
//
//  Created by Filosuf on 08.02.2023.
//

import UIKit

protocol CategorySettingsViewControllerProtocol {
    func categorySettingsDidUpdated(categories: [TrackerCategory])
}

final class CategorySettingsViewController: UIViewController {
    // MARK: - Properties
    private let coordinator: SettingsFlowCoordinator
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let indexPathEditCategory: IndexPath?

    private enum Constants {
        static let maxTitleLength = 38
    }

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .Custom.blackDay
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.backgroundColor = .Custom.actionBackground
        textField.placeholder = "Введите название категории"
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.leftViewMode = UITextField.ViewMode.always
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
        textField.leftView = UIView(frame:CGRect(x:0, y:0, width:10, height:textField.frame.height))
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .Custom.red
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let saveButton = CustomButton(title: "Готово")

    // MARK: - Initialiser
    init(coordinator: SettingsFlowCoordinator, trackerCategoryStore: TrackerCategoryStoreProtocol, indexPathEditCategory: IndexPath?) {
        self.coordinator = coordinator
        self.trackerCategoryStore = trackerCategoryStore
        self.indexPathEditCategory = indexPathEditCategory
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
        setupAction()
        layout()
        hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }

    // MARK: - Methods
    private func setupAction() {
        saveButton.tapAction = { [weak self] in
            self?.onSaveAction()
        }
    }
// TODO: - make save new/update category in Core Data
    private func onSaveAction() {
        let newTitle = nameTextField.text ?? ""
        updateCategories(with: newTitle)
        coordinator.pop()
    }

    private func updateCategories(with title: String){
        if let indexPath = indexPathEditCategory,
           let editCategory = trackerCategoryStore.object(at: indexPath) {
            trackerCategoryStore.updateCategoryTitle(previous: editCategory.title, new: title)
        } else {
            let newTrackerCategory = TrackerCategory(title: title, trackers: [])
            trackerCategoryStore.addCategory(newTrackerCategory)
        }
    }

    private func setupView() {
        title = "Новая категория"
        saveButton.isEnabled = false
        saveButton.updateBackground(backgroundColor: .Custom.gray)
        if let indexPath = indexPathEditCategory,
           let editCategory = trackerCategoryStore.object(at: indexPath) {
            nameTextField.text = editCategory.title
            title = "Редактирование категории"
        }
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let isNotAvailable = trackerCategoryStore.isDuplicateOfCategory(with: text)

        if !text.isEmpty, text.count <= Constants.maxTitleLength, !isNotAvailable {
            saveButton.isEnabled = true
            saveButton.updateBackground(backgroundColor: .Custom.blackDay)
        }
        else {
            saveButton.isEnabled = false
            saveButton.updateBackground(backgroundColor: .Custom.gray)
        }

        if isNotAvailable {
            warningLabel.text = "Имя категории уже используется"
        } else if Array(text).count > Constants.maxTitleLength {
            warningLabel.text = "Ограничение \(Constants.maxTitleLength) символов"
        } else {
            warningLabel.text = ""
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

    private func layout() {
        [nameTextField,
         warningLabel,
         saveButton
        ].forEach { view.addSubview($0)}

        NSLayoutConstraint.activate([
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),

            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            warningLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            warningLabel.heightAnchor.constraint(equalToConstant: 22),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

//MARK: - UITextFieldDelegate
extension CategorySettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

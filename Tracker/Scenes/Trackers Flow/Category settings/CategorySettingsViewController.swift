//
//  CategorySettingsViewController.swift
//  Tracker
//
//  Created by Filosuf on 08.02.2023.
//

import UIKit

protocol CategorySettingsViewControllerProtocol {
    func categorySettingsDidUpdated(newTitle: String)
}

final class CategorySettingsViewController: UIViewController {
    // MARK: - Properties
    private let coordinator: SettingsFlowCoordinator
    private var category: TrackerCategory?
    private let delegate: CategorySettingsViewControllerProtocol

    private var currentCategory: TrackerCategory?

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .Custom.text
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

    private let saveButton = CustomButton(title: "Готово")

    // MARK: - Initialiser
    init(coordinator: SettingsFlowCoordinator, category: TrackerCategory?, delegate: CategorySettingsViewControllerProtocol) {
        self.coordinator = coordinator
        self.category = category
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
        hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }

    // MARK: - Methods
    private func taps() {
        saveButton.tapAction = { [weak self] in
            let newTitle = self?.nameTextField.text ?? ""
            self?.delegate.categorySettingsDidUpdated(newTitle: newTitle)
            self?.coordinator.pop()
        }
    }

    private func setupView() {
        title = "Новая категория"
        saveButton.isEnabled = false
        saveButton.updateBackground(backgroundColor: .Custom.gray)
        if let category = category {
            nameTextField.text = category.title
            title = "Редактирование категории"
        }
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            if text != "", Array(text).count < 39 {
                saveButton.isEnabled = true
                saveButton.updateBackground(backgroundColor: .Custom.text)
            }
            else {
                saveButton.isEnabled = false
                saveButton.updateBackground(backgroundColor: .Custom.gray)
            }
        }
    }

    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    private func layout() {
        [nameTextField,
         saveButton
        ].forEach { view.addSubview($0)}

        NSLayoutConstraint.activate([
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),

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

//
//  CategorySettingsViewController.swift
//  Tracker
//
//  Created by Filosuf on 08.02.2023.
//

import UIKit

final class CategorySettingsViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: CategorySettingsViewModel

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .Custom.blackDay
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.backgroundColor = .Custom.actionBackground
        textField.placeholder = "categorySettingsNameTextFieldPlaceholder".localized
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

    private let saveButton = CustomButton(title: "done".localized)

    // MARK: - Initialiser
    init(viewModel: CategorySettingsViewModel) {
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
        navigationItem.hidesBackButton = true
        setupAction()
        bind()
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
            self?.viewModel.handleSaveButtonTap()
        }
    }

    private func bind() {
        viewModel.$savingIsAvailable.bind { [weak self] newValue in
            self?.updateSaveButtonState(isOn: newValue)
        }
        viewModel.$warningText.bind { [weak self] warning in
            self?.warningLabel.text = warning
        }
    }

    private func setupView() {
        title = "categorySettingsNewTitle".localized
        updateSaveButtonState(isOn: viewModel.savingIsAvailable)
        if let categoryTitle = viewModel.categoryTitle {
            nameTextField.text = categoryTitle
            title = "categorySettingsNewTitle".localized
        }
    }

    private func updateSaveButtonState(isOn: Bool) {
        saveButton.isEnabled = isOn
        saveButton.updateBackground(backgroundColor: isOn ? .Custom.blackDay : .Custom.gray)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        viewModel.changeCategoryTitle(title: text)
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

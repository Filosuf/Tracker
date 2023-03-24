//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Filosuf on 24.03.2023.
//

import UIKit

final class OnboardingViewController: UIViewController {
    // MARK: - Properties
    private let buttonTitle = "Вот это технологии"
    private let backgroundImage: UIImage?
    private let titleString: String?

    var tapAction: (() -> Void)?

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = backgroundImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = titleString
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var skipButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .Custom.blackDay
        button.setTitle(buttonTitle, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapSkipButton), for: .touchUpInside)
        return button
    }()


    // MARK: - Initialiser
    init(backgroundImage: UIImage?, title: String?) {
        self.backgroundImage = backgroundImage
        self.titleString = title
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }

    // MARK: - Methods
    @objc private func didTapSkipButton() {
        tapAction?()
    }

    private func layout() {

        [backgroundImageView,
         titleLabel,
         skipButton].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),


            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -160),

            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            skipButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

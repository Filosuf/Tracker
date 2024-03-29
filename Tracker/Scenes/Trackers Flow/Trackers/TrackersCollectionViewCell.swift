//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Filosuf on 31.01.2023.
//

import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "TrackersCollectionViewCell"

    var buttonAction: (() -> Void)?

    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SF Pro", size: 14)
        label.backgroundColor = .Custom.emojiBackground
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = UIFont(name: "SF Pro", size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let numberOfDayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .Custom.blackDay
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let plusButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 34 / 2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(plus), for: .touchUpInside)
        return button
    }()

    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods
    func setupCell(tracker: Tracker, numberOfMarks: Int, isTodayCompleted: Bool, isHabit: Bool) {
        nameLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        if isHabit {
            numberOfDayLabel.text = String(format: "day".localized, numberOfMarks)
        } else {
            numberOfDayLabel.text = String(format: "time".localized, numberOfMarks)
        }
        colorView.backgroundColor = tracker.color

        if isTodayCompleted {
            plusButton.setTitle("✓", for: .normal)
            plusButton.backgroundColor = tracker.color.withAlphaComponent(0.7)
        } else {
            plusButton.setTitle("+", for: .normal)
            plusButton.backgroundColor = tracker.color.withAlphaComponent(1)
        }
    }

    @objc private func plus() {
        buttonAction?()
    }

    private func layout() {
        let interval: CGFloat = 12

        [emojiLabel, nameLabel].forEach { colorView.addSubview($0) }

        [colorView, numberOfDayLabel, plusButton].forEach { contentView.addSubview($0) }

        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -42),

            emojiLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: interval),
            emojiLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: interval),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),

            nameLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: interval),
            nameLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -interval),
            nameLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -interval),

            numberOfDayLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            numberOfDayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: interval),

            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -interval),
            plusButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
}

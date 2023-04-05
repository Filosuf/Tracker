//
//  TrackersSubviewCell.swift
//  Tracker
//
//  Created by Filosuf on 05.04.2023.
//

import UIKit

final class TrackersSubviewCell: UIView {
    // MARK: - Properties
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

    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods
    func setupView(tracker: Tracker) {
        nameLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        colorView.backgroundColor = tracker.color
    }

    private func layout() {
        let interval: CGFloat = 12

        [emojiLabel, nameLabel].forEach { colorView.addSubview($0) }

        [colorView].forEach { addSubview($0) }

        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: topAnchor),
            colorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            colorView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emojiLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: interval),
            emojiLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: interval),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),

            nameLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: interval),
            nameLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -interval),
            nameLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -interval)
        ])
    }
}

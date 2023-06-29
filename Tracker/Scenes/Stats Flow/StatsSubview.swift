//
//  StatsSubview.swift
//  Tracker
//
//  Created by Filosuf on 27.06.2023.
//

import UIKit

//final class StatsSubview: UIView {
//    // MARK: - Properties
//
//
//    // MARK: - Initialiser
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        layout()
//    }
//
//    required init?(coder aDecoder: NSCoder)
//    {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - Methods
//    private func layout() {
//        [emptyStatsImage,
//         emptyStatsLabel
//        ].forEach { view in
//            view.translatesAutoresizingMaskIntoConstraints = false
//            self.view.addSubview(view)
//        }
//
//        NSLayoutConstraint.activate([
//            emptyStatsImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            emptyStatsImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            emptyStatsImage.heightAnchor.constraint(equalToConstant: 80),
//            emptyStatsImage.widthAnchor.constraint(equalToConstant: 80),
//
//            emptyStatsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            emptyStatsLabel.topAnchor.constraint(equalTo: emptyStatsImage.bottomAnchor, constant: 8)
//        ])
//    }
//
//}

final class StatsSubview: UIStackView {
    private lazy var factLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addArrangedSubview(factLabel)
        addArrangedSubview(descriptionLabel)

        axis = .vertical
        spacing = 2
        alignment = .leading

        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)

        layer.borderWidth = 1
        layer.cornerRadius = 16
        clipsToBounds = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let gradient = UIImage.gradientImage(bounds: bounds,
                                             colors: [UIColor(named: "gradient3") ?? .black,
                                                      UIColor(named: "gradient2") ?? .black,
                                                      UIColor(named: "gradient1") ?? .black])
        layer.borderColor = UIColor(patternImage: gradient).cgColor
    }

    func update(fact: String, description: String) {
        factLabel.text = fact
        descriptionLabel.text = description
    }
}

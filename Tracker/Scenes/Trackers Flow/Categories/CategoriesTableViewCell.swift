//
//  CategoriesTableViewCell.swift
//  Tracker
//
//  Created by Filosuf on 08.02.2023.
//

import UIKit

final class CategoriesTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "CategoriesTableViewCell"

    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "checkmark")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .Custom.actionBackground
        selectionStyle = UITableViewCell.SelectionStyle.none
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods
    func configure(title: String, isSetCheckmark: Bool) {
        label.text = title
        checkmarkImage.isHidden = !isSetCheckmark
    }

    private func layout() {
        let basicSpaceInterval: CGFloat = 16
        [label, checkmarkImage].forEach { contentView.addSubview($0) }

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: basicSpaceInterval),

            checkmarkImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -basicSpaceInterval),
            checkmarkImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImage.heightAnchor.constraint(equalToConstant: 24),
            checkmarkImage.widthAnchor.constraint(equalToConstant: 24)
        ])
    }

}

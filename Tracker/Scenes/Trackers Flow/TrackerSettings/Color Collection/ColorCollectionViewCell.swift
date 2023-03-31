//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Filosuf on 03.03.2023.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "ColorCollectionViewCell"
    private var color = UIColor.white

    private let colorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 6
        return label
    }()

    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 6
        layer.borderWidth = 3
        layer.borderColor = UIColor.white.cgColor
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods
    override var isSelected: Bool {
        didSet{
            UIView.animate(withDuration: 0.3) {
                self.layer.borderColor = self.isSelected ? self.color.cgColor : UIColor.white.cgColor
            }
        }
    }

    func setupCell(color: UIColor?) {
        colorLabel.backgroundColor = color
        self.color = color ?? .white
    }

    private func layout() {
        [colorLabel].forEach { contentView.addSubview($0) }

        NSLayoutConstraint.activate([
            colorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorLabel.heightAnchor.constraint(equalToConstant: 40),
            colorLabel.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
}

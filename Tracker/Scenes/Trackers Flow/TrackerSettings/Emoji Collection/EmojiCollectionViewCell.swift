//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Filosuf on 02.03.2023.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "EmojiCollectionViewCell"

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SF Pro", size: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods
    override var isSelected: Bool {
        didSet{
            if self.isSelected {
                UIView.animate(withDuration: 0.3) {
                    self.backgroundColor = .Custom.emojiSelected
                }
            }
            else {
                UIView.animate(withDuration: 0.3) {
                    self.backgroundColor = .white
                }
            }
        }
    }

    func setupCell(emoji: String) {
        emojiLabel.text = emoji
    }

    private func layout() {
        [emojiLabel].forEach { contentView.addSubview($0) }

        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.heightAnchor.constraint(equalToConstant: 38),
            emojiLabel.widthAnchor.constraint(equalToConstant: 32)
        ])
    }
}

//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Filosuf on 06.02.2023.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

    static let identifier = "ScheduleTableViewCell"

    var buttonAction: ((Bool) -> Void)?

    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let switchButton: UISwitch = {
        let switchButton = UISwitch()
        switchButton.onTintColor = .Custom.blue
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.addTarget(self, action:  #selector(buttonPressed), for: .touchUpInside)
        return switchButton
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .Custom.actionBackground
        selectionStyle = UITableViewCell.SelectionStyle.none
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buttonPressed() {
        buttonAction?(switchButton.isOn)
    }

    func configure(title: String, isOn: Bool) {
        label.text = title
        switchButton.isOn = isOn
    }

    private func layout() {
        let basicSpaceInterval: CGFloat = 16
        [label, switchButton].forEach { contentView.addSubview($0) }

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: basicSpaceInterval),

            switchButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -basicSpaceInterval),
            switchButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

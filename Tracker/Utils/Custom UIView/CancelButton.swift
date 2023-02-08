//
//  CancelButton.swift
//  Tracker
//
//  Created by Filosuf on 06.02.2023.
//

import UIKit

final class CancelButton: UIButton {

    var tapAction: (() -> Void)?

    init(title: String = "", titleColor: UIColor = .red, backgroundColor: UIColor? = .white) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setButton(title: title, titleColor: titleColor, backgroundColor: backgroundColor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setButton(title: String, titleColor: UIColor,  backgroundColor: UIColor?) {
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.backgroundColor = backgroundColor
        layer.cornerRadius = 16
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1
        clipsToBounds = true
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false
    }

    func updateButton(title: String,  backgroundColor: UIColor?) {
        setTitle(title, for: .normal)
        self.backgroundColor = backgroundColor
    }

    @objc private func buttonTapped() {
        tapAction?()
    }

}

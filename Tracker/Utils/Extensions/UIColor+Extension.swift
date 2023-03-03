//
//  UIColor+Extension.swift
//  Tracker
//
//  Created by Filosuf on 05.02.2023.
//

import UIKit

extension UIColor {
    enum Custom {
        static var text: UIColor? { UIColor(named: "text") }
        static var actionBackground: UIColor? { UIColor(named: "actionBackground") }
        static var emojiBackground: UIColor? { UIColor(named: "emojiBackground") }
        static var gray: UIColor? { UIColor(named: "gray") }
        static var blue: UIColor? { UIColor(named: "blue") }
        static var red: UIColor? { UIColor(named: "red") }

        static var emojiSelected: UIColor? { UIColor(named: "emojiSelected") }
    }
}

//
//  UIColor+Extension.swift
//  Tracker
//
//  Created by Filosuf on 05.02.2023.
//

import UIKit

extension UIColor {
    enum Custom {
        static var blackDay: UIColor? { UIColor(named: "blackDay") }
        static var whiteDay: UIColor? { UIColor(named: "whiteDay") }
        static var actionBackground: UIColor? { UIColor(named: "actionBackground") }
        static var emojiBackground: UIColor? { UIColor(named: "emojiBackground") }
        static var gray: UIColor? { UIColor(named: "gray") }
        static var blue: UIColor? { UIColor(named: "blue") }
        static var red: UIColor? { UIColor(named: "red") }
        static var orange: UIColor? { UIColor(named: "orange") }

        static var emojiSelected: UIColor? { UIColor(named: "emojiSelected") }
    }

    public convenience init?(hex: String?) {
        let r, g, b, a: CGFloat

        guard let hex = hex else { return nil }
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            } else if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x0000ff) >> 0) / 255

                    self.init(red: r, green: g, blue: b, alpha: 1)
                    return
                }
            }
        }

        return nil
    }

    var hexValue: String {
        var color = self

        if color.cgColor.numberOfComponents < 4 {
            let c = color.cgColor.components!
            color = UIColor(red: c[0], green: c[0], blue: c[0], alpha: c[1])
        }
        if color.cgColor.colorSpace!.model != .rgb {
            return "#FFFFFF"
        }
        let c = color.cgColor.components!
        return String(format: "#%02X%02X%02X", Int(c[0]*255.0), Int(c[1]*255.0), Int(c[2]*255.0))
    }
}

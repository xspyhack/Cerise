//
//  UIColor+Hex.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/21.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hex = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .uppercased()

        if hex.hasPrefix("#") {
            hex = String(hex[hex.index(after: hex.startIndex)...])
        }

        if hex.count != 6 {
            // fatalError()
            // clear color
            self.init(white: 0.0, alpha: 0.0)
        } else {
            var rgbValue: UInt32 = 0
            let scanner = Scanner(string: hex)
            scanner.scanLocation = 0
            scanner.scanHexInt32(&rgbValue)

            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0xFF) / 255.0

            self.init(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
}

//
//  Shadowability.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/22.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

struct Shadow {
    let offset: CGSize
    let blur: CGFloat
    let opacity: Float
    let color: UIColor

    enum Style {
        case standard
        case wide
    }

    init(style: Style) {
        switch style {
        case .standard:
            self.init(offset: CGSize(width: 0, height: 0.6),
                      blur: 2,
                      opacity: 0.3,
                      color: .black)
        case .wide:
            self.init(offset: CGSize(width: 0, height: 4),
                      blur: 6,
                      opacity: 0.2,
                      color: .gray)
        }
    }

    init(offset: CGSize,
         blur: CGFloat,
         opacity: Float,
         color: UIColor) {
        self.offset = offset
        self.blur = blur
        self.opacity = opacity
        self.color = color
    }

    func apply(to view: UIView) {
        apply(to: view.layer)
    }

    func apply(to layer: CALayer) {
        layer.shadowOffset = offset
        layer.shadowRadius = blur
        layer.shadowOpacity = opacity
        layer.shadowColor = color.cgColor
    }
}

protocol Shadowability {
    func applyShadow(style: Shadow.Style)
}

extension Shadowability where Self: UIView {
    func applyShadow(style: Shadow.Style) {
        Shadow(style: .standard).apply(to: self)
    }
}

extension UIView: Shadowability {}

//
//  UIView+Layout.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/16.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

public extension Cerise where Base: UIView {
    func layout(using builder: (LayoutBuilder) -> Void) {
        base.translatesAutoresizingMaskIntoConstraints = false
        builder(LayoutBuilder(view: base))
    }

    var edgesAnchor: [AnyLayoutAnchor] {
        return [
            AnyLayoutAnchor(base.topAnchor),
            AnyLayoutAnchor(base.leadingAnchor),
            AnyLayoutAnchor(base.bottomAnchor),
            AnyLayoutAnchor(base.trailingAnchor),
        ]
    }

    var centerAnchor: [AnyLayoutAnchor] {
        return [AnyLayoutAnchor(base.centerXAnchor), AnyLayoutAnchor(base.centerYAnchor)]
    }

    var sizeAnchor: [NSLayoutDimension] {
        return [base.widthAnchor, base.heightAnchor]
    }
}

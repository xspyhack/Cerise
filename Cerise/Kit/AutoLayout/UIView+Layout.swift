//
//  UIView+Layout.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/16.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

public extension Cerise where Base: UIView {
    public func layout(using builder: (LayoutBuilder) -> Void) {
        base.translatesAutoresizingMaskIntoConstraints = false
        builder(LayoutBuilder(view: base))
    }

    public var edgesAnchor: [AnyLayoutAnchor] {
        return [
            AnyLayoutAnchor(base.topAnchor),
            AnyLayoutAnchor(base.leadingAnchor),
            AnyLayoutAnchor(base.bottomAnchor),
            AnyLayoutAnchor(base.trailingAnchor),
        ]
    }

    public var centerAnchor: [AnyLayoutAnchor] {
        return [AnyLayoutAnchor(base.centerXAnchor), AnyLayoutAnchor(base.centerYAnchor)]
    }

    public var sizeAnchor: [AnyLayoutAnchor] {
        return [AnyLayoutAnchor(base.widthAnchor), AnyLayoutAnchor(base.heightAnchor)]
    }
}

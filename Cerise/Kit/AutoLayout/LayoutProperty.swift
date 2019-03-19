//
//  LayoutProperty.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/16.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

public struct LayoutProperty<Anchor: LayoutAnchor> {
    private let anchor: Anchor

    init(anchor: Anchor) {
        self.anchor = anchor
    }
}

public extension LayoutProperty {
    public func equal(to otherAnchor: Anchor, offset constant: CGFloat = 0) {
        anchor.constraint(equalTo: otherAnchor,
                          constant: constant).isActive = true
    }

    public func greaterThanOrEqual(to otherAnchor: Anchor,
                                   offset constant: CGFloat = 0) {
        anchor.constraint(greaterThanOrEqualTo: otherAnchor,
                          constant: constant).isActive = true
    }

    public func lessThanOrEqual(to otherAnchor: Anchor,
                                offset constant: CGFloat = 0) {
        anchor.constraint(lessThanOrEqualTo: otherAnchor,
                          constant: constant).isActive = true
    }
}

public extension LayoutProperty where Anchor: LayoutDimension {
    public func equal(toConstant constant: CGFloat) {
        anchor.constraint(equalToConstant: constant).isActive = true
    }

    public func greaterThanOrEqual(toConstant constant: CGFloat) {
        anchor.constraint(greaterThanOrEqualToConstant: constant).isActive = true
    }

    public func lessThanOrEqual(toConstant constant: CGFloat) {
        anchor.constraint(lessThanOrEqualToConstant: constant).isActive = true
    }
}

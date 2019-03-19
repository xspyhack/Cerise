//
//  LayoutAnchor.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/16.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

/// AutoLayout DSL extended from https://www.swiftbysundell.com/posts/building-dsls-in-swift
/// https://gist.github.com/xspyhack/9718545f7606c062d2c4caa2ec6262a3
public protocol LayoutAnchor {
    func constraint(equalTo anchor: Self,
                    constant: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualTo anchor: Self,
                    constant: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualTo anchor: Self,
                    constant: CGFloat) -> NSLayoutConstraint
}

public protocol LayoutDimension: LayoutAnchor {
    func constraint(equalToConstant constant: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualToConstant constant: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualToConstant constant: CGFloat) -> NSLayoutConstraint
}

extension NSLayoutAnchor: LayoutAnchor {}
extension NSLayoutDimension: LayoutDimension {}

protocol AnyLayoutAnchorBox {
    func unbox<T: LayoutAnchor>() -> T?

    func constraint(equalTo anchor: AnyLayoutAnchorBox,
                    constant: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualTo anchor: AnyLayoutAnchorBox,
                    constant: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualTo anchor: AnyLayoutAnchorBox,
                    constant: CGFloat) -> NSLayoutConstraint
}

struct ConcreteLayoutAnchorBox<Base: LayoutAnchor>: AnyLayoutAnchorBox {
    var base: Base

    init(_ base: Base) {
        self.base = base
    }

    func unbox<T: LayoutAnchor>() -> T? {
        return (self as AnyLayoutAnchorBox as? ConcreteLayoutAnchorBox<T>)?.base
    }

    func constraint(equalTo anchor: AnyLayoutAnchorBox,
                    constant: CGFloat) -> NSLayoutConstraint {
        return base.constraint(equalTo: anchor.unbox()!, constant: constant)
    }

    func constraint(greaterThanOrEqualTo anchor: AnyLayoutAnchorBox,
                    constant: CGFloat) -> NSLayoutConstraint {
        return base.constraint(greaterThanOrEqualTo: anchor.unbox()!, constant: constant)
    }

    func constraint(lessThanOrEqualTo anchor: AnyLayoutAnchorBox,
                    constant: CGFloat) -> NSLayoutConstraint {
        return base.constraint(lessThanOrEqualTo: anchor.unbox()!, constant: constant)
    }
}

public struct AnyLayoutAnchor {
    private var box: AnyLayoutAnchorBox

    public init<T: LayoutAnchor>(_ box: T) {
        self.box = ConcreteLayoutAnchorBox(box)
    }
}

extension AnyLayoutAnchor: LayoutAnchor {
    public func constraint(equalTo anchor: AnyLayoutAnchor, constant: CGFloat) -> NSLayoutConstraint {
        return box.constraint(equalTo: anchor.box, constant: constant)
    }

    public func constraint(greaterThanOrEqualTo anchor: AnyLayoutAnchor, constant: CGFloat) -> NSLayoutConstraint {
        return box.constraint(greaterThanOrEqualTo: anchor.box, constant: constant)
    }

    public func constraint(lessThanOrEqualTo anchor: AnyLayoutAnchor, constant: CGFloat) -> NSLayoutConstraint {
        return box.constraint(lessThanOrEqualTo: anchor.box, constant: constant)
    }
}

//
//  AutoLayout.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/16.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

public func + <Anchor: LayoutAnchor>(lhs: Anchor, rhs: CGFloat) -> (Anchor, CGFloat) {
    return (lhs, rhs)
}

public func - <Anchor: LayoutAnchor>(lhs: Anchor, rhs: CGFloat) -> (Anchor, CGFloat) {
    return (lhs, -rhs)
}

public func == <Anchor: LayoutAnchor>(lhs: LayoutProperty<Anchor>, rhs: (Anchor, CGFloat)) {
    lhs.equal(to: rhs.0, offset: rhs.1)
}

public func == <Anchor: LayoutAnchor>(lhs: LayoutProperty<Anchor>, rhs: Anchor) {
    lhs.equal(to: rhs)
}

public func == <Anchor: LayoutDimension>(lhs: LayoutProperty<Anchor>, rhs: CGFloat) {
    lhs.equal(toConstant: rhs)
}

public func == <Anchor: LayoutDimension>(lhs: DimensionProperty<Anchor>, rhs: CGSize) {
    lhs.width.equal(toConstant: rhs.width)
    lhs.height.equal(toConstant: rhs.height)
}

public func == <Anchor: LayoutDimension>(lhs: DimensionProperty<Anchor>, rhs: [Anchor]) {
    assert(rhs.count == 2, "Layout anchors count must be 2")
    lhs.width.equal(to: rhs[0])
    lhs.height.equal(to: rhs[1])
}

public func == <Anchor: LayoutAnchor>(lhs: [LayoutProperty<Anchor>], rhs: [Anchor]) {
    assert(lhs.count == rhs.count, "Layout properties count must equal to anchors count")
    zip(lhs, rhs).forEach { $0.equal(to: $1) }
}

public func >= <Anchor: LayoutAnchor>(lhs: LayoutProperty<Anchor>, rhs: (Anchor, CGFloat)) {
    lhs.greaterThanOrEqual(to: rhs.0, offset: rhs.1)
}

public func >= <Anchor: LayoutAnchor>(lhs: LayoutProperty<Anchor>, rhs: Anchor) {
    lhs.greaterThanOrEqual(to: rhs)
}

public func >= <Anchor: LayoutDimension>(lhs: LayoutProperty<Anchor>, rhs: CGFloat) {
    lhs.greaterThanOrEqual(toConstant: rhs)
}

public func <= <Anchor: LayoutAnchor>(lhs: LayoutProperty<Anchor>, rhs: (Anchor, CGFloat)) {
    lhs.lessThanOrEqual(to: rhs.0, offset: rhs.1)
}

public func <= <Anchor: LayoutAnchor>(lhs: LayoutProperty<Anchor>, rhs: Anchor) {
    lhs.lessThanOrEqual(to: rhs)
}

public func <= <Anchor: LayoutDimension>(lhs: LayoutProperty<Anchor>, rhs: CGFloat) {
    lhs.lessThanOrEqual(toConstant: rhs)
}

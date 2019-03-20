//
//  LayoutBuilder.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/16.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

public class LayoutBuilder {
    public lazy var leading = property(with: view.leadingAnchor)
    public lazy var trailing = property(with: view.trailingAnchor)
    public lazy var top = property(with: view.topAnchor)
    public lazy var left = property(with: view.leftAnchor)
    public lazy var bottom = property(with: view.bottomAnchor)
    public lazy var right = property(with: view.rightAnchor)
    public lazy var width = property(with: view.widthAnchor)
    public lazy var height = property(with: view.heightAnchor)
    public lazy var centerX = property(with: view.centerXAnchor)
    public lazy var centerY = property(with: view.centerYAnchor)
    public lazy var firstBaseline = property(with: view.firstBaselineAnchor)
    public lazy var lastBaseline = property(with: view.lastBaselineAnchor)

    public lazy var edges = properties(with: view.cerise.edgesAnchor)
    public lazy var center = properties(with: view.cerise.centerAnchor)
    public lazy var size = DimensionProperty(width: width, height: height)

    private let view: UIView

    init(view: UIView) {
        self.view = view
    }

    private func property<Anchor: LayoutAnchor>(with anchor: Anchor) -> LayoutProperty<Anchor> {
        return LayoutProperty(anchor: anchor)
    }

    private func properties<Anchor: LayoutAnchor>(with anchors: [Anchor]) -> [LayoutProperty<Anchor>] {
        return anchors.map { LayoutProperty(anchor: $0) }
    }
}

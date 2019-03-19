//
//  SafeCollection.swift
//  Prelude
//
//  Created by bl4ckra1sond3tre on 2016/12/11.
//  Copyright © 2016 blessingsoftware. All rights reserved.
//

import Foundation

public struct SafeCollection<Base: Collection> {
    private var base: Base

    public init(_ base: Base) {
        self.base = base
    }

    public typealias Index = Base.Index
    public var startIndex: Index {
        return base.startIndex
    }

    public var endIndex: Index {
        return base.endIndex
    }

    public subscript(index: Base.Index) -> Base.Iterator.Element? {
        if base.distance(from: startIndex, to: index) >= 0 && base.distance(from: index, to: endIndex) > 0 {
            return base[index]
        }
        return nil
    }

    public subscript(bounds: Range<Base.Index>) -> Base.SubSequence? {
        if base.distance(from: startIndex, to: bounds.lowerBound) >= 0 && base.distance(from: bounds.upperBound, to: endIndex) >= 0 {
            return base[bounds]
        }
        return nil
    }

    /// Allows to chain “.safe” without side effects
    var safe: SafeCollection<Base> {
        return self
    }
}

public extension Collection {
    var safe: SafeCollection<Self> {
        return SafeCollection(self)
    }
}

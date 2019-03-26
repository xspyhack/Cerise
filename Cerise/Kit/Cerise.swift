//
//  Cerise.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation

public final class Cerise<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol CeriseCompatible {
    associatedtype BaseType

    var cerise: Cerise<BaseType> { get }
    static var cerise: Cerise<BaseType>.Type { get }
}

public extension CeriseCompatible {
    var cerise: Cerise<Self> {
        return Cerise(self)
    }

    static var cerise: Cerise<Self>.Type {
        return Cerise<Self>.self
    }
}

extension NSObject: CeriseCompatible {}

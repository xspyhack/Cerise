//
//  Observable+Optional.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/21.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import RxSwift
import RxCocoa

public protocol OptionalType {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    /// Cast `Optional<Wrapped>` to `Wrapped?`
    public var value: Wrapped? {
        return self
    }
}

public extension ObservableType where Self.E: OptionalType {
    /**
     Unwraps and filters out `nil` elements.
     - returns: `Observable` of source `Observable`'s elements, with `nil` elements filtered out.
     */

    func filterNil() -> Observable<E.Wrapped> {
        return self.flatMap { element -> Observable<E.Wrapped> in
            guard let value = element.value else {
                return Observable<E.Wrapped>.empty()
            }
            return Observable<E.Wrapped>.just(value)
        }
    }
}

public extension Driver where SharedSequence.E: OptionalType {
    func filterNil() -> Driver<E.Wrapped> {
        return self.flatMap { element -> Driver<E.Wrapped> in
            guard let value = element.value else {
                return Driver<E.Wrapped>.empty()
            }
            return Driver<E.Wrapped>.just(value)
        }
    }
}

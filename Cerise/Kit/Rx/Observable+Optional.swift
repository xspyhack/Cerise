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

public extension ObservableType where Self.Element: OptionalType {
    /**
     Unwraps and filters out `nil` elements.
     - returns: `Observable` of source `Observable`'s elements, with `nil` elements filtered out.
     */

    func filterNil() -> Observable<Element.Wrapped> {
        return self.flatMap { element -> Observable<Element.Wrapped> in
            guard let value = element.value else {
                return Observable<Element.Wrapped>.empty()
            }
            return Observable<Element.Wrapped>.just(value)
        }
    }
}

public extension Driver where SharedSequence.Element: OptionalType {
    func filterNil() -> Driver<Element.Wrapped> {
        return self.flatMap { element -> Driver<Element.Wrapped> in
            guard let value = element.value else {
                return Driver<Element.Wrapped>.empty()
            }
            return Driver<Element.Wrapped>.just(value)
        }
    }

    func compactMap<Result>(_ transform: @escaping (Element) throws -> Result?) -> Driver<Result> {
        return self.flatMap { element -> Driver<Result> in
            guard let value = try? transform(element) else {
                return Driver<Result>.empty()
            }
            return Driver<Result>.just(value)
        }
    }
}

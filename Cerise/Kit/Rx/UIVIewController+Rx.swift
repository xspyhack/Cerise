//
//  UIVIewController+Rx.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/25.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        let source = methodInvoked(#selector(Base.viewDidLoad))
            .map { _ in
                return ()
            }
        return ControlEvent(events: source)
    }

    var viewWillAppear: ControlEvent<Bool> {
        let source = methodInvoked(#selector(Base.viewWillAppear))
            .map { arg in
                return try castOrThrow(Bool.self, arg[0])
            }
        return ControlEvent(events: source)
    }

    var viewDidAppear: ControlEvent<Bool> {
        let source = methodInvoked(#selector(Base.viewDidAppear))
            .map { arg in
                return try castOrThrow(Bool.self, arg[0])
            }
        return ControlEvent(events: source)
    }

    var viewWillDisappear: ControlEvent<Bool> {
        let source = methodInvoked(#selector(Base.viewWillDisappear))
            .map { arg in
                return try castOrThrow(Bool.self, arg[0])
            }
        return ControlEvent(events: source)    }

    var viewDidDisappear: ControlEvent<Bool> {
        let source = methodInvoked(#selector(Base.viewDidDisappear))
            .map { arg in
                return try castOrThrow(Bool.self, arg[0])
            }
        return ControlEvent(events: source)
    }
}

private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}

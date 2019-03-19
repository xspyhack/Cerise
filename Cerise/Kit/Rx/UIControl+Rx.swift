//
//  UIControl+Rx.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 14/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIControl {
    static func valuePublic<T, ControlType: UIControl>(_ control: ControlType, getter:  @escaping (ControlType) -> T, setter: @escaping (ControlType, T) -> Void) -> ControlProperty<T> {
        let values: Observable<T> = Observable.deferred { [weak control] in
            guard let existingSelf = control else {
                return Observable.empty()
            }

            return (existingSelf as UIControl).rx.controlEvent([.allEditingEvents, .valueChanged])
                .flatMap { _ in
                    return control.map { Observable.just(getter($0)) } ?? Observable.empty()
                }
                .startWith(getter(existingSelf))
        }
        return ControlProperty(values: values, valueSink: Binder(control) { control, value in
            setter(control, value)
        })
    }
}

extension Reactive where Base: UIButton {
    /**
     Reactive wrapper for `isSelected` property.
     */
    public var selected: ControlProperty<Bool> {
        return UIControl.rx.valuePublic(
            self.base,
            getter: { uiButton in
                uiButton.isSelected
            }, setter: { uiButton, value in
                uiButton.isSelected = value
            })
    }
}

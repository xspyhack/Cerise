//
//  UITextField+Rx.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/19.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UITextField {
    var delegate: DelegateProxy<UITextField, UITextFieldDelegate> {
        return RxTextFieldDelegateProxy.proxy(for: base)
    }

    var didBeginEditing: ControlEvent<Void> {
        return ControlEvent<Void>(events: delegate.methodInvoked(#selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)))
            .map { _ in
                return ()
            })
    }

    var didEndEditing: ControlEvent<Void> {
        return ControlEvent<Void>(events: delegate.methodInvoked(#selector(UITextFieldDelegate.textFieldDidEndEditing(_:)))
            .map { _ in
                return ()
            })
    }
}

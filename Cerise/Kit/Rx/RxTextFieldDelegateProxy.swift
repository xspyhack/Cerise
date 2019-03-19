//
//  RxTextFieldDelegateProxy.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/19.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RxTextFieldDelegateProxy: DelegateProxy<UITextField, UITextFieldDelegate>, DelegateProxyType, UITextFieldDelegate {

    /// Typed parent object.
    private(set) weak var textField: UITextField?

    init(textField: ParentObject) {
        self.textField = textField
        super.init(parentObject: textField, delegateProxy: RxTextFieldDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        register {
            RxTextFieldDelegateProxy(textField: $0)
        }
    }

    static func currentDelegate(for object: UITextField) -> UITextFieldDelegate? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: UITextFieldDelegate?, to object: UITextField) {
        object.delegate = delegate
    }
}

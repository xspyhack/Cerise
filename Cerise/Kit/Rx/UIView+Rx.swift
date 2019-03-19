//
//  UIView+Rx.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 24/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIView {
    public var isVisible: Binder<Bool> {
        return Binder(self.base) { view, visible in
            view.isHidden = !visible
        }
    }
}

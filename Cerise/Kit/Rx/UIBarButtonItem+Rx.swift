//
//  UIBarButtonItem+Rx.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/4/5.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UIBarButtonItem {
    public var isVisible: Binder<Bool> {
        return Binder(self.base) { barItem, visible in
            barItem.tintColor = visible ? UIColor.cerise.tint : UIColor.clear
            barItem.isEnabled = visible
        }
    }
}

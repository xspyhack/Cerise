//
//  ViewStyle.swift
//  Cerise
//
//  Created by alex.huo on 2019/7/5.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

struct ViewStyle<T> {
    let with: (T) -> Void
}

extension Cerise where Base: UIView {
    func apply(_ style: ViewStyle<Base>) {
        style.with(base)
    }
}

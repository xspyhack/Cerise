//
//  TraitEnvironment.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

struct TraitEnvironment {
    /// 屏幕
    ///
    /// - all: 全面屏
    /// - normal: 普通屏
    enum Screen {
        case all
        case normal
    }

    /// 圆角
    ///
    /// - rouned: 圆角
    /// - normal: 普通角
    enum Corner {
        case rounded
        case normal
    }

    /// 屏幕
    let screen: Screen

    /// 圆角
    let corner: Corner

    init() {
        let size = UIScreen.main.bounds.size
        screen = (size.width == 375.0 && size.height == 812.0) || (size.width == 414.0 && size.height == 896.0) ? .all : .normal
        corner = (size.width == 375.0 && size.height == 812.0) || (size.width == 414.0 && size.height == 896.0) ? .rounded : .normal
    }
}

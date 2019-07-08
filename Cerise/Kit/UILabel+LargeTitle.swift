//
//  UILabel+LargeTitle.swift
//  Cerise
//
//  Created by alex.huo on 2019/7/5.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

extension Cerise where Base: UILabel {
    static var largeTitle: ViewStyle<UILabel> {
        return ViewStyle<UILabel> {
            $0.numberOfLines = 2
            $0.font = UIFont.systemFont(ofSize: 34.0, weight: .bold)
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.4
            $0.lineBreakMode = .byTruncatingTail
        }
    }
}

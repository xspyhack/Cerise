//
//  UIScrollView+Cerise.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/24.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

extension Cerise where Base: UIScrollView {
    func scrollToTop(animated: Bool) {
        let offset: CGFloat = base.adjustedContentInset.top
        let topOffset = CGPoint(x: base.adjustedContentInset.left, y: -offset)
        base.setContentOffset(topOffset, animated: animated)
    }

    func scrollToBottom(animated: Bool) {
        let offset: CGFloat = base.adjustedContentInset.bottom
        let bottomOffset = CGPoint(x: base.adjustedContentInset.left, y: max(0, base.contentSize.height - base.bounds.height + offset))
        base.setContentOffset(bottomOffset, animated: animated)
    }
}

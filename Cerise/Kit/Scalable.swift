//
//  Scalable.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/22.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

protocol Scalable {
    func beginScaling()
    func endScaling()
}

extension Scalable where Self: UIView {
    func beginScaling() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: {
                self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            },
            completion: nil)
    }

    func endScaling() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: {
                self.transform = .identity
            },
            completion: nil)
    }
}

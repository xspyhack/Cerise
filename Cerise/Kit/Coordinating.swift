//
//  Coordinating.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/16.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation

/// Defines coordinators interfaces
public protocol Coordinating {
    /// child coordinators

    /// Coodinator start
    func start()

    /// Coodinator stop
    func stop()
}

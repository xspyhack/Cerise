//
//  Matter.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation

struct Matter {
    ///
    let id: String

    ///
    let title: String

    ///
    let days: Int

    ///
    let happenedAt: TimeInterval
}

extension Matter {
    static func mock() -> [Matter] {
        return [
            Matter(id: UUID().uuidString, title: "Cherry", days: 233, happenedAt: Date().timeIntervalSince1970),
            Matter(id: UUID().uuidString, title: "Blessing", days: -233, happenedAt: Date().timeIntervalSince1970),
            Matter(id: UUID().uuidString, title: "Lily", days: 23, happenedAt: Date().timeIntervalSince1970),
            Matter(id: UUID().uuidString, title: "Alex", days: 33, happenedAt: Date().timeIntervalSince1970),
            Matter(id: UUID().uuidString, title: "Cerise", days: -3, happenedAt: Date().timeIntervalSince1970),
            Matter(id: UUID().uuidString, title: "Prelude", days: 131, happenedAt: Date().timeIntervalSince1970),
            Matter(id: UUID().uuidString, title: "Kit", days: 324, happenedAt: Date().timeIntervalSince1970),
            Matter(id: UUID().uuidString, title: "Router", days: -979, happenedAt: 0),
            Matter(id: UUID().uuidString, title: "Coordinator", days: 3, happenedAt: Date().timeIntervalSinceNow),
            Matter(id: UUID().uuidString, title: "Logger", days: 230, happenedAt: 342),
            Matter(id: UUID().uuidString, title: "Logging", days: 230, happenedAt: 242),
            Matter(id: UUID().uuidString, title: "Swift", days: 230, happenedAt: 42),
        ]
    }
}

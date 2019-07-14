//
//  Matter.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation
import SwiftUI

/// A model that represents a matter.
struct Matter: Codable, Identifiable {
    /// The matter’s unique identifier.
    let id: String

    /// The title for the matter.
    let title: String

    /// The tag for the matter.
    let tag: Tagble

    /// The original occurrence date of the matter.
    let occurrenceDate: Date

    /// The notes associated with the matter.
    let notes: String?

    /// This will be removed after Swift 5.
    init(id: String,
         title: String,
         tag: Tagble = Tagble.allCases.randomElement() ?? .none,
         occurrenceDate: Date,
         notes: String? = nil) {
        self.id = id
        self.title = title
        self.tag = tag
        self.occurrenceDate = occurrenceDate
        self.notes = notes
    }
}

extension Matter {
    enum Kind: Int {
        case past
        case upcoming
    }
}

extension Matter: Hashable {
    static func == (lhs: Matter, rhs: Matter) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Matter {
    static func mock() -> [Matter] {
        return [
            Matter(id: UUID().uuidString, title: "Cherry", occurrenceDate: Date(timeIntervalSince1970: 233)),
            Matter(id: UUID().uuidString, title: "Blessing", occurrenceDate: Date()),
            Matter(id: UUID().uuidString, title: "Lily", occurrenceDate: Date(timeIntervalSinceNow: 22_330)),
            Matter(id: UUID().uuidString, title: "Alex", occurrenceDate: Date(timeInterval: 111_233, since: Date())),
            Matter(id: UUID().uuidString, title: "Cerise", occurrenceDate: Date()),
            Matter(id: UUID().uuidString, title: "Prelude", occurrenceDate: Date()),
            Matter(id: UUID().uuidString, title: "Kit", occurrenceDate: Date()),
            Matter(id: UUID().uuidString, title: "Router", occurrenceDate: Date()),
            Matter(id: UUID().uuidString, title: "Coordinator", occurrenceDate: Date()),
            Matter(id: UUID().uuidString, title: "Logger", occurrenceDate: Date()),
            Matter(id: UUID().uuidString, title: "Keldeo", occurrenceDate: Date()),
            Matter(id: UUID().uuidString, title: "Swift", occurrenceDate: Date()),
        ]
    }
}

//
//  HapticGenerator.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/18.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

struct HapticGenerator {
    enum HatpicType: Int {
        case selection
        case impact
        case impactHeavy
        case impactMedium
        case impactLight
    }

    static func trigger(with hapticType: HatpicType) {
        switch hapticType {
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        case .impact:
            let generator = UIImpactFeedbackGenerator()
            generator.prepare()
            generator.impactOccurred()
        case .impactHeavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            generator.impactOccurred()
        case .impactMedium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        case .impactLight:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        }
    }
}

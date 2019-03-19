//
//  Environment.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

struct Environment {

    /// 开发环境
    ///
    /// - release: 发布版本
    /// - debug: 开发版本
    enum EnvironmentType: String {
        case release
        case debug
    }

    /// for save to user defaults
    static let typeKey = "com.cerise.environment.type"

    static var type: EnvironmentType {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }

    let trait: TraitEnvironment
    let type: EnvironmentType
    let userDefaults: UserDefaults

    init(trait: TraitEnvironment = TraitEnvironment(),
         type: EnvironmentType = Environment.type,
         userDefaults: UserDefaults = UserDefaults.standard) {
        self.trait = trait
        self.type = type
        self.userDefaults = userDefaults
    }
}

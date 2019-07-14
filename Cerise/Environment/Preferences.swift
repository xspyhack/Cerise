//
//  Preferences.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/4/5.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation

enum Preferences {
    enum Accessibility: String, CaseIterable {
        case normal
        case modern
        case clean

        var title: String {
            return rawValue.capitalized
        }

        var isVerbose: Bool {
            return self == .normal
        }

        static let key = "accessibility" + Preferences.suffix
    }

    enum Info: String {
        case version
        case build
        case git

        var key: String {
            return rawValue + Preferences.suffix
        }
    }

    private static let suffix = "_preference"

    static func setUp() {
        // Info
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: String(kCFBundleVersionKey)) as! String
        UserDefaults.standard.set("\(version) (\(build))", forKey: Info.version.key)
    }
}

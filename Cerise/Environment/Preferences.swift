//
//  Preferences.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/4/5.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

enum Preferences {
    enum Accessibility: String, CaseIterable {
        case normal
        case modern
        case clean

        var title: String {
            return NSLocalizedString(rawValue.capitalized, comment: "Accessibility case")
        }

        var isVerbose: Bool {
            return self == .normal
        }

        static let key = "accessibility" + Preferences.suffix
    }

    static let accessibility = BehaviorRelay<Accessibility>(value: .normal)

    enum Info: String {
        case version
        case build
        case git

        var key: String {
            return rawValue + Preferences.suffix
        }
    }

    private static let suffix = "_preference"
    private static let disposeBag = DisposeBag()

    static func setUp() {
        func updateAccessibility() {
            let value = UserDefaults.standard.string(forKey: Accessibility.key) ?? "Normal"
            if let accessibility = Accessibility(rawValue: value.lowercased()) {
                Preferences.accessibility.accept(accessibility)
            }
        }

        updateAccessibility()

        Preferences.accessibility
            .distinctUntilChanged()
            .subscribe(onNext: { style in
                UserDefaults.standard.set(style.rawValue.capitalized, forKey: Accessibility.key)
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UserDefaults.didChangeNotification)
            .subscribe(onNext: { _ in
                updateAccessibility()
            })
            .disposed(by: disposeBag)

        // Info
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: String(kCFBundleVersionKey)) as! String
        UserDefaults.standard.set("\(version) (\(build))", forKey: Info.version.key)
    }
}

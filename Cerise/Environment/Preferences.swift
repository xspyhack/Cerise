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
    enum Accessibility: Int, CaseIterable {
        case normal
        case modern

        var title: String {
            switch self {
            case .normal:
                return "Normal"
            case .modern:
                return "Modern"
            }
        }
    }

    static let accessibility = BehaviorRelay<Accessibility>(value: .normal)

    private static let disposeBag = DisposeBag()

    static func setUp() {
        let key = "com.cerise.accessibility"
        if let accessibility = Accessibility(rawValue: UserDefaults.standard.integer(forKey: key)) {
            Preferences.accessibility.accept(accessibility)
        }

        Preferences.accessibility
            .subscribe(onNext: { style in
                UserDefaults.standard.set(style.rawValue, forKey: key)
            })
            .disposed(by: disposeBag)
    }
}

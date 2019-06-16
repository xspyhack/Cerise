//
//  Appearances.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/6/16.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

enum Appearances {
    static func setUp() {
        setUpWindow()
        setUpNavigationBar()
        setUpTabBar()
        setUpTableView()
        setUpTextView()
        setUpTextField()
    }

    private static func setUpWindow() {
        let window = UIApplication.shared.keyWindow
        window?.tintColor = UIColor.cerise.tint
        window?.backgroundColor = .white
    }

    private static func setUpNavigationBar() {
        let appearance = UINavigationBar.appearance()
        appearance.barTintColor = UIColor.black.withAlphaComponent(0.9)
        appearance.tintColor = UIColor.cerise.tint
        //appearance.setBackgroundImage(UIImage(color: UIColor.red.withAlphaComponent(0.99)), for: .default)
        appearance.shadowImage = UIImage()
        appearance.isTranslucent = false
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.cerise.tint]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.cerise.tint]
    }

    private static func setUpTabBar() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage(color: UIColor.black.withAlphaComponent(0.99))
        UITabBar.appearance().tintColor = UIColor(named: "BK20") // tabbar active
        UITabBar.appearance().unselectedItemTintColor = UIColor(named: "BK70") // tabbar inactive
    }

    private static func setUpTableView() {
        UITableViewHeaderFooterView.appearance().tintColor = .black
        let appearance = UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
        appearance.textColor = UIColor.white.withAlphaComponent(0.78)
        appearance.shadowColor = .white
        // font will be reset when reuse, damn it
        //appearance.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }

    private static func setUpTextView() {
        let appearance = UITextView.appearance()
        appearance.keyboardAppearance = .dark
    }

    private static func setUpTextField() {
        let appearance = UITextField.appearance()
        appearance.keyboardAppearance = .dark
    }
}

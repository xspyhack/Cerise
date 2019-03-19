//
//  AppDelegate.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import Keldeo

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    /// key window
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setUpLogger()
        setUpAppearance()
        Router.register()
        startMainStory()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return Router.route(to: url, isFromLaunching: true)
    }
}

extension AppDelegate {
    func startMainStory() {
        let rootViewController = UINavigationController()
        window?.rootViewController = rootViewController
        let coordinator = AppCoodinator(rootViewController: rootViewController)
        Router.shared.appCoordinator = coordinator
        coordinator.start()
        window?.makeKeyAndVisible()
    }
}

extension AppDelegate {
    private func setUpLogger() {
        let formatter = LogFormatter()

        if Environment.type == .debug {
            let consoleLogger = ConsoleLogger(level: .debug, formatter: formatter)
            Logger.shared.add(AnyLogger(consoleLogger))
        } else {
            let fileManager = DefaultFileManager()
            if let fileLogger = FileLogger(level: .info, formatter: formatter, fileManager: fileManager) {
                Logger.shared.add(AnyLogger(fileLogger))
                print("Log directory: \(fileManager.directory)")
            }
        }
    }

    private func setUpAppearance() {
        window?.tintColor = UIColor.cerise.tint
        window?.backgroundColor = .white

        // UINavigationBar
        let appearance = UINavigationBar.appearance()
        appearance.barTintColor = UIColor.black.withAlphaComponent(0.9)
        appearance.tintColor = UIColor.cerise.tint
        //appearance.setBackgroundImage(UIImage(color: UIColor.red.withAlphaComponent(0.99)), for: .default)
        appearance.shadowImage = UIImage()
        appearance.isTranslucent = false
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.cerise.tint]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.cerise.tint]

        // UITabBar
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage(color: UIColor.black.withAlphaComponent(0.99))
        UITabBar.appearance().tintColor = UIColor(named: "BK20") // tabbar active
        UITabBar.appearance().unselectedItemTintColor = UIColor(named: "BK70") // tabbar inactive

        // UITableView
        UITableViewHeaderFooterView.appearance().tintColor = .black
        let labelAppearance = UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
        labelAppearance.textColor = .white
        labelAppearance.shadowColor = .white
    }
}

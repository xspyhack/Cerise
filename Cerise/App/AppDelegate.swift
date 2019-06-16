//
//  AppDelegate.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    /// key window
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setUpLogger()
        setUpRouter()
        setUpAppearances()
        setUpPreferences()
        startBootstrap()
        startMainStory()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return Router.route(to: url, isFromLaunching: true)
    }
}

extension AppDelegate {
    func startBootstrap() {
        let bootstrap = Bootstrap()
        bootstrap.start()
    }

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
        Logger.setUp()
    }

    private func setUpRouter() {
        Router.register()
    }

    private func setUpAppearances() {
        Appearances.setUp()
    }

    private func setUpPreferences() {
        Preferences.setUp()
    }
}

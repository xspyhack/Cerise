//
//  AppCoordinator.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

struct AppCoodinator: Coordinating {
    weak var navigationController: UINavigationController?

    init(rootViewController: UINavigationController) {
        self.navigationController = rootViewController
    }

    func start() {
        let coordinator = MainCoodinator(navigationController: navigationController)
        coordinator.start()
    }

    func stop() {
        // do nothing
    }
}

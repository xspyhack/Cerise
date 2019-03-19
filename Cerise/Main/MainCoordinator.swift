//
//  MainCoordinator.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxCocoa

struct MainCoodinator: Coordinating {
    weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func start() {
        let viewController = Storyboard.main.viewController(of: MainViewController.self)
        navigationController?.setViewControllers([viewController], animated: true)
        //navigationController?.pushViewController(viewController, animated: true)
    }

    func stop() {
        navigationController?.popViewController(animated: true)
    }

    func makeMattersViewController() -> UIViewController {
        return MattersViewController()
    }
}

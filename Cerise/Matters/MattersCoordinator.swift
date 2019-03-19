//
//  MattersCoordinator.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/3.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

struct MattersCoodinator: Coordinating {
    weak var parentViewController: UIViewController?

    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }

    func start() {
        let viewController = MattersViewController()
        parentViewController?.addChild(viewController)
        viewController.didMove(toParent: parentViewController)
    }

    func stop() {
    }

    func makeMatterViewController() -> UIViewController {
        return MatterViewController()
    }
}

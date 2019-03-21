//
//  MatterCoordinator.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/21.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

struct MatterCoordinator: Coordinating {
    weak var parentViewController: UIViewController?
    let matter: Matter

    init(parentViewController: UIViewController, matter: Matter) {
        self.parentViewController = parentViewController
        self.matter = matter
    }

    func start() {
        let viewController = MatterViewController(viewModel: MatterViewModel(matter: matter))
        parentViewController?.present(viewController, animated: true, completion: nil)
    }

    func stop() {
        parentViewController?.dismiss(animated: true, completion: nil)
    }
}

//
//  MattersCoordinator.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/3.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxSwift

struct MattersCoodinator: Coordinating {
    weak var parentViewController: UIViewController?
    let disposeBag = DisposeBag()

    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }

    func start() {
        guard let parentViewController = parentViewController else {
            return
        }

        let viewModel = MattersViewModel()
        let viewController = MattersViewController(viewModel: viewModel)
        parentViewController.addChild(viewController)
        parentViewController.view.addSubview(viewController.view)
        viewController.view.cerise.layout { builder in
            builder.edges == parentViewController.view.cerise.edgesAnchor
        }
        viewController.didMove(toParent: parentViewController)

        viewModel.outputs.showMatterDetail
            .subscribe(onNext: { [unowned viewController] matter in
                let coordinator = MatterCoordinator(parentViewController: viewController, matter: matter)
                coordinator.start()
            })
            .disposed(by: disposeBag)
    }

    func stop() {
        parentViewController?.children.first?.removeFromParent()
    }
}

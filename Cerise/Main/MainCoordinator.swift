//
//  MainCoordinator.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

struct MainCoodinator: Coordinating {
    weak var navigationController: UINavigationController?
    private let disposeBag = DisposeBag()

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func start() {
        let viewController = Storyboard.main.viewController(of: MainViewController.self)
        viewController.rx.viewDidLoad
            .subscribe(onNext: { [unowned viewController] in
                let coordinator = MattersCoodinator(parentViewController: viewController)
                coordinator.start()
            })
            .disposed(by: disposeBag)
        Router.shared.delegate = viewController
        navigationController?.setViewControllers([viewController], animated: true)
    }

    func stop() {
        Router.shared.delegate = nil
        navigationController?.popViewController(animated: true)
    }

    func makeMattersViewController() -> UIViewController {
        return MattersViewController()
    }
}

//
//  MainViewController.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

final class MainViewController: BaseViewController {
    private var containerView: UIView = UIView()

    private lazy var mattersViewController = MattersViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Cerise"
        view.backgroundColor = UIColor.black
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.rightBarButtonItem = addItem
        Preferences.accessibility.map { $0 == .normal }
            .bind(to: addItem.rx.isVisible)
            .disposed(by: disposeBag)

        addChild(mattersViewController)
        view.addSubview(mattersViewController.view)
        mattersViewController.view.cerise.layout { builder in
            builder.edges == view.cerise.edgesAnchor
        }
        mattersViewController.didMove(toParent: self)

        addItem.rx.tap
            .bind(to: mattersViewController.viewModel.inputs.addAction)
            .disposed(by: disposeBag)
    }
}

extension MainViewController: CherryTransitioning {
    var anchorView: UIView? {
        return mattersViewController.anchorView
    }
}

extension MainViewController: RoutingCoordinatorDelegate {
    func coordinatorRepresentation() -> RoutingCoordinator.Representaion {
        return .present(from: self, animated: true)
    }
}

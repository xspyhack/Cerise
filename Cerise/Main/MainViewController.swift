//
//  MainViewController.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import Keldeo

final class MainViewController: BaseViewController {
    private var containerView: UIView = UIView()

    private lazy var mattersViewController = MattersViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Cerise"
        view.backgroundColor = UIColor.black
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        let logoItem = UIBarButtonItem(image: UIImage(named: "Logo"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = logoItem

        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.rightBarButtonItem = addItem

        Preferences.accessibility
            .subscribe(onNext: { [weak navigationItem] style in
                switch style {
                case .normal:
                    navigationItem?.leftBarButtonItem = logoItem
                    navigationItem?.rightBarButtonItem = addItem
                case .modern:
                    navigationItem?.leftBarButtonItem = nil
                    navigationItem?.rightBarButtonItem = logoItem
                case .clean:
                    navigationItem?.leftBarButtonItem = nil
                    navigationItem?.rightBarButtonItem = nil
                }
            })
            .disposed(by: disposeBag)

        addChild(mattersViewController)
        view.addSubview(mattersViewController.view)
        mattersViewController.view.cerise.layout { builder in
            builder.edges == view.cerise.edgesAnchor
        }
        mattersViewController.didMove(toParent: self)

        logoItem.rx.tap
            .subscribe(onNext: { [weak self] in
                let vc = SettingsViewController()
                self?.present(vc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        addItem.rx.tap
            .bind(to: mattersViewController.viewModel.inputs.addAction)
            .disposed(by: disposeBag)

        if Preferences.cloud.value == .enabled {
            // Check iCloud available
             DispatchQueue.global().async {
                 Log.i("availabel \(Cloud.shared.isAvailable())")
             }
        }
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

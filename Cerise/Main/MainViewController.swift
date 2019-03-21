//
//  MainViewController.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {
    private var containerView: UIView = UIView()

    private lazy var mattersViewController = MattersViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Cerise"
        view.backgroundColor = UIColor.black
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

//        view.addSubview(containerView)
//        containerView.cerise.layout { builder in
//            builder.edges == view.cerise.edgesAnchor
//        }

        addChild(mattersViewController)
        view.addSubview(mattersViewController.view)
        mattersViewController.view.cerise.layout { builder in
            builder.edges == view.cerise.edgesAnchor
        }
        mattersViewController.didMove(toParent: self)
    }
}

extension MainViewController: CherryTransitioning {
    var anchorView: UIView? {
        return mattersViewController.anchorView
    }
}

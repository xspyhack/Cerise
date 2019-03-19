//
//  ComposerViewController.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/18.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

final class ComposerViewController: BaseViewController {
    private(set) lazy var editorViewController: EditorViewController = {
        let vc = EditorViewController()
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = doneItem

        doneItem.rx.tap
            .do(onNext: {
                HapticGenerator.trigger(with: .impactMedium)
            })
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        addChild(editorViewController)
        view.addSubview(editorViewController.view)
        editorViewController.view.cerise.layout { builder in
            builder.edges == view.cerise.edgesAnchor
        }
        editorViewController.didMove(toParent: self)
    }
}

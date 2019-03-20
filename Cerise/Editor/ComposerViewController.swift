//
//  ComposerViewController.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/18.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

final class ComposerViewController: BaseViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)

        transitioningDelegate = self
        modalPresentationStyle = .custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

        let editorViewModel = EditorViewModel()
        let editorViewController = EditorViewController(viewModel: editorViewModel)
        addChild(editorViewController)
        view.addSubview(editorViewController.view)
        editorViewController.view.cerise.layout { builder in
            builder.edges == view.cerise.edgesAnchor
        }
        editorViewController.didMove(toParent: self)

        let viewModel = ComposerViewModel(matter: editorViewModel.outputs.matter, validated: editorViewModel.outputs.validated)

        viewModel.outputs.isPostEnabled
            .drive(doneItem.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.outputs.dismiss
            .drive(onNext: { [weak self] in
                self?.view.endEditing(true)
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

extension ComposerViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        guard presented == self else {
            return nil
        }

        let presentationController = ModalPresentationController(presentedViewController: presented,
                                                                 presenting: presenting)
        let bounds = UIApplication.shared.keyWindow?.bounds ?? UIScreen.main.bounds
        presentationController.contentHeight = (bounds.height / 5 * 4).rounded(.up)
        presentationController.handleView.backgroundColor = UIColor.cerise.tint
        presentationController.bottomView.backgroundColor = .white
        return presentationController
    }
}

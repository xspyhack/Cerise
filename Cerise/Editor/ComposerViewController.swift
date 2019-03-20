//
//  ComposerViewController.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/18.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

final class ComposerViewController: BaseViewController {

    private lazy var editorViewController = EditorViewController(viewModel: EditorViewModel())

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
//        navigationItem.largeTitleDisplayMode = .always
//        navigationController?.navigationBar.prefersLargeTitles = true
//
//        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
//        navigationItem.rightBarButtonItem = doneItem

//        doneItem.rx.tap
//            .do(onNext: {
//                HapticGenerator.trigger(with: .impactMedium)
//            })
//            .subscribe(onNext: { [weak self] in
//                self?.dismiss(animated: true, completion: nil)
//            })
//            .disposed(by: disposeBag)

        addChild(editorViewController)
        view.addSubview(editorViewController.view)
        editorViewController.view.cerise.layout { builder in
            builder.edges == view.cerise.edgesAnchor
        }
        editorViewController.didMove(toParent: self)

        let postButton = UIButton(type: .custom)
        postButton.setBackgroundImage(UIImage(color: UIColor.cerise.tint), for: .normal)
        postButton.layer.cornerRadius = 33
        postButton.layer.masksToBounds = true
        postButton.setImage(UIImage(named: "post")?.withRenderingMode(.alwaysTemplate), for: .normal)
        postButton.tintColor = UIColor.white
        postButton.imageEdgeInsets = UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11)
        view.addSubview(postButton)
        postButton.cerise.layout { builder in
            builder.centerX == view.centerXAnchor
            builder.bottom == view.safeAreaLayoutGuide.bottomAnchor - 60
            builder.size == CGSize(width: 66, height: 66)
        }

        // MARK: ViewModel binding
        let editorViewModel = editorViewController.viewModel
        let viewModel = ComposerViewModel(matter: editorViewModel.outputs.matter, validated: editorViewModel.outputs.validated)

        postButton.rx.tap
            .bind(to: viewModel.inputs.post)
            .disposed(by: disposeBag)

        viewModel.outputs.isPostEnabled
            .drive(postButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.outputs.dismiss
            .do(onNext: {
                HapticGenerator.trigger(with: .impactMedium)
            })
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
        //presentationController.setContentScrollView(editorViewController.tableView)
        presentationController.handleView.backgroundColor = UIColor.cerise.tint
        presentationController.bottomView.backgroundColor = .white
        return presentationController
    }
}

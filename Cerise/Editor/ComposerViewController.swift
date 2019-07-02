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

    private enum Constant {
        static let postButtonSize = CGSize(width: 60, height: 60)
        static let postButtonBottom: CGFloat = 60
    }

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

        title = "New Matter"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = UIColor.cerise.dark

        let navigationBar = UINavigationBar()
        navigationBar.prefersLargeTitles = true
        navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        let navigationItem = UINavigationItem()
        navigationItem.title = "New Matter"
        navigationBar.items = [navigationItem]

        view.addSubview(navigationBar)
        navigationBar.cerise.layout { builder in
            builder.leading == view.leadingAnchor
            builder.trailing == view.trailingAnchor
            builder.height == 96
            builder.top == view.topAnchor
        }

        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        navigationItem.leftBarButtonItem = cancelItem

        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = doneItem

        let postButton = UIButton(type: .custom)
        postButton.setImage(UIImage(named: "Post"), for: .normal)
        postButton.setBackgroundImage(UIImage(color: UIColor.cerise.tint), for: .normal)
        postButton.tintColor = .white
        postButton.layer.cornerRadius = 16
        postButton.layer.masksToBounds = true

        navigationBar.addSubview(postButton)
        postButton.cerise.layout { builder in
            builder.size == CGSize(width: 32, height: 32)
            builder.trailing == navigationBar.trailingAnchor - 12
            builder.bottom == navigationBar.bottomAnchor - 12
        }

        Preferences.accessibility
            .subscribe(onNext: { style in
                postButton.isHidden = style.isVerbose

                switch style {
                case .normal:
                    navigationItem.leftBarButtonItem = cancelItem
                    navigationItem.rightBarButtonItem = doneItem
                case .modern:
                    navigationItem.leftBarButtonItem = cancelItem
                    navigationItem.rightBarButtonItem = nil
                case .clean:
                    navigationItem.leftBarButtonItem = nil
                    navigationItem.rightBarButtonItem = nil
                }
            })
            .disposed(by: disposeBag)

        addChild(editorViewController)
        view.addSubview(editorViewController.view)
        editorViewController.view.cerise.layout { builder in
            builder.top == navigationBar.bottomAnchor
            builder.leading == view.leadingAnchor
            builder.trailing == view.trailingAnchor
            builder.bottom == view.bottomAnchor
        }
        editorViewController.didMove(toParent: self)

        // MARK: ViewModel binding

        let editorViewModel = editorViewController.viewModel
        let viewModel = ComposerViewModel(matter: editorViewModel.outputs.matter, validated: editorViewModel.outputs.validated)

        postButton.rx.tap
            .bind(to: viewModel.inputs.post)
            .disposed(by: disposeBag)

        doneItem.rx.tap
            .bind(to: viewModel.inputs.post)
            .disposed(by: disposeBag)

        cancelItem.rx.tap
            .bind(to: viewModel.inputs.cancel)
            .disposed(by: disposeBag)

        viewModel.outputs.isPostEnabled
            .drive(postButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.outputs.isPostEnabled
            .drive(doneItem.rx.isEnabled)
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
        presentationController.setContentScrollView(editorViewController.tableView)
        presentationController.handleView.backgroundColor = UIColor.cerise.tint
        presentationController.bottomView.backgroundColor = UIColor.cerise.dark
        return presentationController
    }
}

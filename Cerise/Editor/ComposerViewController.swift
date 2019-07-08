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
        static let navigationBarHeight: CGFloat = 96.0
        static let largeTitleViewHeight: CGFloat = 52.0
        static let largeTitleLabelHeight: CGFloat = 40.0
        static let postButtonSize = CGSize(width: 32, height: 32)
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

        view.backgroundColor = UIColor.cerise.dark

        let navigationBar = UINavigationBar()
        navigationBar.prefersLargeTitles = true
        navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        let navigationItem = UINavigationItem()
        navigationBar.items = [navigationItem]

        view.addSubview(navigationBar)
        navigationBar.cerise.layout { builder in
            builder.leading == view.leadingAnchor
            builder.trailing == view.trailingAnchor
            builder.height == Constant.navigationBarHeight
            builder.top == view.topAnchor
        }

        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        navigationItem.leftBarButtonItem = cancelItem

        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = doneItem

        let largeTitleView = UIView()
        navigationBar.addSubview(largeTitleView)
        largeTitleView.cerise.layout { builder in
            builder.height == Constant.largeTitleViewHeight
            builder.leading == navigationBar.leadingAnchor
            builder.trailing == navigationBar.trailingAnchor
            builder.bottom == navigationBar.bottomAnchor
        }

        let postButton = UIButton(type: .custom)
        postButton.setImage(UIImage(named: "Post"), for: .normal)
        postButton.setBackgroundImage(UIImage(color: UIColor.cerise.tint), for: .normal)
        postButton.tintColor = .white
        postButton.layer.cornerRadius = Constant.postButtonSize.height / 2
        postButton.layer.masksToBounds = true

        largeTitleView.addSubview(postButton)
        postButton.cerise.layout { builder in
            builder.size == Constant.postButtonSize
            builder.trailing == largeTitleView.trailingAnchor - 16.0
            builder.bottom == largeTitleView.bottomAnchor - 12
        }

        let largeTitleLabel = UILabel()
        largeTitleLabel.text = "New Matter"
        largeTitleLabel.textColor = .white
        largeTitleLabel.cerise.apply(UILabel.cerise.largeTitle)

        largeTitleView.addSubview(largeTitleLabel)
        largeTitleLabel.cerise.layout { builder in
            builder.centerY == largeTitleView.centerYAnchor
            builder.leading == largeTitleView.leadingAnchor + 16.0
            builder.trailing == postButton.leadingAnchor - 10.0
            builder.height == Constant.largeTitleLabelHeight
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

        editorViewModel.title
            .map { $0 == "" ? "New Matter" : $0 }
            .bind(to: largeTitleLabel.rx.text)
            .disposed(by: disposeBag)

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
        presentationController.preferredContentHeight = (bounds.height / 5 * 4).rounded(.up)
        presentationController.setContentScrollView(editorViewController.tableView)
        presentationController.handleView.backgroundColor = UIColor.cerise.tint
        presentationController.bottomView.backgroundColor = UIColor.cerise.dark
        return presentationController
    }
}

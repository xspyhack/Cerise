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

        view.backgroundColor = UIColor.cerise.dark

        addChild(editorViewController)
        view.addSubview(editorViewController.view)
        editorViewController.view.cerise.layout { builder in
            builder.edges == view.cerise.edgesAnchor
        }
        editorViewController.didMove(toParent: self)

        let cancelButton = UIButton(type: .system)
        cancelButton.layer.cornerRadius = 8
        cancelButton.layer.masksToBounds = true
        cancelButton.setBackgroundImage(UIImage(color: UIColor(named: "BK30") ?? .gray), for: .highlighted)
        cancelButton.setTitle("Cancel", for: .normal) // ×
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        cancelButton.tintColor = UIColor.cerise.tint
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.addSubview(cancelButton)
        cancelButton.cerise.layout { builder in
            builder.leading == view.leadingAnchor + 8
            builder.top == view.topAnchor + 2
        }

        let doneButton = UIButton(type: .system)
        doneButton.layer.cornerRadius = 8
        doneButton.layer.masksToBounds = true
        doneButton.setBackgroundImage(UIImage(color: UIColor(named: "BK30") ?? .gray), for: .highlighted)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        doneButton.tintColor = UIColor.cerise.tint
        doneButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.addSubview(doneButton)
        doneButton.cerise.layout { builder in
            builder.trailing == view.trailingAnchor - 8
            builder.top == view.topAnchor + 2
        }

        let postButton = UIButton(type: .custom)
        postButton.layer.cornerRadius = min(Constant.postButtonSize.width, Constant.postButtonSize.height) / 2
        postButton.layer.masksToBounds = true
        postButton.setImage(UIImage(named: "Post")?.withRenderingMode(.alwaysTemplate), for: .normal)
        postButton.setBackgroundImage(UIImage(color: UIColor(named: "BK30") ?? .gray), for: .highlighted)
        postButton.tintColor = UIColor.cerise.tint
        postButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.addSubview(postButton)
        postButton.cerise.layout { builder in
            builder.centerX == view.centerXAnchor
            builder.bottom == view.safeAreaLayoutGuide.bottomAnchor - Constant.postButtonBottom
            builder.size == Constant.postButtonSize
        }

        Preferences.accessibility
            .subscribe(onNext: { style in
                switch style {
                case .normal:
                    cancelButton.isHidden = false
                    doneButton.isHidden = false
                    postButton.isHidden = true
                case .modern:
                    cancelButton.isHidden = true
                    doneButton.isHidden = true
                    postButton.isHidden = false
                }
            })
            .disposed(by: disposeBag)

        // MARK: ViewModel binding

        let editorViewModel = editorViewController.viewModel
        let viewModel = ComposerViewModel(matter: editorViewModel.outputs.matter, validated: editorViewModel.outputs.validated)

        postButton.rx.tap
            .bind(to: viewModel.inputs.post)
            .disposed(by: disposeBag)

        doneButton.rx.tap
            .bind(to: viewModel.inputs.post)
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .bind(to: viewModel.inputs.cancel)
            .disposed(by: disposeBag)

        viewModel.outputs.isPostEnabled
            .drive(postButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.outputs.isPostEnabled
            .drive(doneButton.rx.isEnabled)
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

//
//  MatterViewController.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class MatterViewController: BaseViewController {
    private(set) lazy var whenLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.cerise.tint
        label.textAlignment = .center
        return label
    }()

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private(set) lazy var notesTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 18.0, left: 12.0, bottom: 18.0, right: 12.0)
        textView.textColor = UIColor.cerise.text
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor(named: "BK10")?.withAlphaComponent(0.5)
        textView.keyboardDismissMode = .interactive
        textView.keyboardAppearance = .dark
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()

    private enum Constant {
        static let contentHeight: CGFloat = 300
        static let margin: CGFloat = 24
        static let whenLabelBottom: CGFloat = 24
    }

    let viewModel: MatterViewModelType

    init(viewModel: MatterViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        registerForPreviewing(with: self, sourceView: view)

        let contentView = UIView()
        contentView.backgroundColor = .black
        view.addSubview(contentView)
        contentView.cerise.layout { builder in
            builder.top == view.topAnchor
            builder.leading == view.leadingAnchor
            builder.trailing == view.trailingAnchor
            builder.height == Constant.contentHeight
        }

        contentView.addSubview(titleLabel)
        titleLabel.cerise.layout { builder in
            builder.leading == contentView.leadingAnchor + Constant.margin
            builder.trailing == contentView.trailingAnchor - Constant.margin
            builder.centerY == contentView.centerYAnchor
        }

        contentView.addSubview(whenLabel)
        whenLabel.cerise.layout { builder in
            builder.bottom == contentView.bottomAnchor - Constant.whenLabelBottom
            builder.centerX == contentView.centerXAnchor
        }

        view.addSubview(notesTextView)
        notesTextView.cerise.layout { builder in
            builder.leading == contentView.leadingAnchor
            builder.trailing == contentView.trailingAnchor
            builder.top == contentView.bottomAnchor
            builder.bottom == view.bottomAnchor
        }

        // MARK: Model binding

        viewModel.title
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.when
            .drive(whenLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.notes
            .filterNil()
            .map { text in
                Renderer().render(text: text)
            }
            .drive(notesTextView.rx.attributedText)
            .disposed(by: disposeBag)

         viewModel.tag
            .map { UIColor(hex: $0) }
            .drive(onNext: { [weak self] color in
                 self?.titleLabel.textColor = color
                 self?.whenLabel.textColor = color
            })
            .disposed(by: disposeBag)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

extension MatterViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        HapticGenerator.trigger(with: .impactHeavy)
        dismiss(animated: true, completion: nil)
        return nil
    }
}

extension MatterViewController: CherryTransitioning {
    func transitionController(_ transitionController: CherryTransitionController, didTransitionFrom fromViewController: UIViewController, to toViewController: UIViewController) {
        guard toViewController == self else {
            return
        }

        titleLabel.alpha = 1.0
        whenLabel.alpha = 1.0
        notesTextView.alpha = 1.0
    }

    func transitionController(_ transitionController: CherryTransitionController, willTransitionFrom fromViewController: UIViewController, to toViewController: UIViewController) {
        guard toViewController == self else {
            return
        }

        titleLabel.alpha = 0.0
        whenLabel.alpha = 0.0
        notesTextView.alpha = 0.0
    }

    func animateAlongsideTransitionController(_ transitionController: CherryTransitionController, from fromViewController: UIViewController, to toViewController: UIViewController) {
        if toViewController == self {
            titleLabel.alpha = 1.0
            whenLabel.alpha = 1.0
            notesTextView.alpha = 1.0
        } else {
            titleLabel.alpha = 0.0
            whenLabel.alpha = 0.0
            notesTextView.alpha = 0.0
        }
    }
}

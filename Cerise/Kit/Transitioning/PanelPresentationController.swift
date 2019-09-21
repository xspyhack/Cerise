//
//  PanelPresentationController.swift
//  Cerise
//
//  Created by alex.huo on 2019/9/21.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class PanelPresentationController: UIPresentationController {
    private var maximumContentHeight: CGFloat
    var preferredContentHeight: CGFloat
    var dismissalOffsetThreshold: CGFloat = -20
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8)
    var dismissOnTapped: Bool = false

    var attemptToDismiss = PublishRelay<Void>()

    private var contentHeight: CGFloat {
        return min(maximumContentHeight, preferredContentHeight)
    }

    private lazy var presentedScrollView: PresentedScrollView = {
        let scrollView = PresentedScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        scrollView.presentationController = self
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        //view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.0
        return view
    }()

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapDimmingView(_:)))
        tapGestureRecognizer.delegate = self
        return tapGestureRecognizer
    }()

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        let sceneBounds = UIApplication.shared.keyWindow?.bounds ?? UIScreen.main.bounds
        maximumContentHeight = (sceneBounds.height - UIApplication.shared.statusBarFrame.height).rounded(.up)
        preferredContentHeight = (sceneBounds.height / 5 * 4).rounded(.up)

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override var presentedView: UIView? {
        return presentedScrollView
    }

    override public var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return CGRect.zero
        }

        return containerView.bounds
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView else {
            return
        }

        // HapticGenerator.trigger(with: .impactLight)
        presentedScrollView.addSubview(contentView)
        contentView.addSubview(presentedViewController.view)
        presentedViewController.view.layer.cornerRadius = contentView.layer.cornerRadius
        presentedViewController.view.layer.masksToBounds = true
        //presentedViewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedViewController.view.frame = contentView.bounds
        containerView.layoutIfNeeded()

        containerView.addSubview(dimmingView)
        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0

        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.5
        }, completion: nil)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        // Remove the dimming view if the presentation was aborted.
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        // Remove the dimming view if the presentation was completed.
        if completed {
            dimmingView.removeFromSuperview()
        }
    }

    override func containerViewDidLayoutSubviews() {
        presentedScrollView.frame = containerView!.bounds
        presentedScrollView.contentSize = presentedScrollView.frame.size
        contentView.frame = CGRect(x: contentInset.left,
                                   y: presentedScrollView.contentSize.height - contentHeight - contentInset.bottom,
                                   width: presentedScrollView.frame.width - contentInset.left - contentInset.right,
                                   height: contentHeight)
    }

    @objc
    private func handleTapDimmingView(_ sender: UITapGestureRecognizer) {
        guard dismissOnTapped else {
            return
        }

        dismiss()
    }

    private func dismiss() {
        attemptToDismiss.accept(())
    }
}

extension PanelPresentationController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < dismissalOffsetThreshold * 4 && !presentedViewController.isBeingPresented {
            scrollView.contentInset = .zero // FIXME
            dismiss()
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.contentOffset.y < dismissalOffsetThreshold {
            dismiss()
        }
    }
}

extension PanelPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == tapGestureRecognizer else {
            return false
        }

        return gestureRecognizer.location(in: presentedScrollView).y < contentView.frame.minY
    }
}

extension PanelPresentationController {
    fileprivate class PresentedScrollView: UIScrollView {
        weak var presentationController: PanelPresentationController?
        var contentScrollView: UIScrollView?

        override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let contentScrollView = contentScrollView, contentScrollView.isScrollEnabled == true else {
                return super.gestureRecognizerShouldBegin(gestureRecognizer)
            }

            if gestureRecognizer == panGestureRecognizer {
                let inContentScrollView = contentScrollView.frame.contains(panGestureRecognizer.location(in: contentScrollView.superview!))
                if inContentScrollView {
                    return contentScrollView.contentSize.height + contentScrollView.adjustedContentInset.top + contentScrollView.adjustedContentInset.bottom <= contentScrollView.frame.size.height
                }
            }
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
    }
}

//
//  ModalPresentationController.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/19.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

final class ModalPresentationController: UIPresentationController {
    var contentHeight = ceil(UIScreen.main.bounds.height / 5 * 4)
    var dismissalOffsetThreshold: CGFloat = -20
    var dismissOnTapped: Bool = false

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

    private let contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()

    let handleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        view.bounds = CGRect(x: 0, y: 0, width: 36, height: 5)
        view.layer.cornerRadius = 2.5
        return view
    }()

    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.0
        return view
    }()

    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapDimmingView(_:)))
        tapGestureRecognizer.delegate = self
        return tapGestureRecognizer
    }()

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
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

        let haptic = UISelectionFeedbackGenerator()
        haptic.prepare()
        haptic.selectionChanged()

        presentedScrollView.addSubview(contentView)
        contentView.addSubview(presentedViewController.view)
        presentedViewController.view.layer.cornerRadius = contentView.layer.cornerRadius
        presentedViewController.view.layer.masksToBounds = true
        presentedViewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedViewController.view.frame = contentView.bounds
        presentedScrollView.addSubview(bottomView)
        presentedViewController.view.addSubview(handleView)
        handleView.layer.zPosition = 100
        containerView.layoutIfNeeded()

        containerView.addSubview(dimmingView)
        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0

        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
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

        presentedViewController.view.bringSubviewToFront(handleView)
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
        contentView.frame = CGRect(x: 0,
                                   y: presentedScrollView.contentSize.height - contentHeight,
                                   width: presentedScrollView.frame.width,
                                   height: contentHeight)
        bottomView.frame = CGRect(x: 0,
                                  y: contentView.frame.maxY,
                                  width: presentedScrollView.frame.width,
                                  height: presentedScrollView.frame.height)
        handleView.center = CGPoint(x: contentView.bounds.width / 2, y: 6 + handleView.bounds.height / 2)
    }

    @objc
    private func handleTapDimmingView(_ sender: UITapGestureRecognizer) {
        guard dismissOnTapped else {
            return
        }
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    private func dismiss() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    private var isContentScrollViewScrollingToTop: Bool = false
    private var lastOffsetY: CGFloat = 0
    private var isScrollingUp = false
    private var offsetObservation: NSKeyValueObservation?
    private var contentScrollViewObservation: NSKeyValueObservation?
    private var containerScrollViewObservation: NSKeyValueObservation?
    private var contentScrollView: UIScrollView?

    func setContentScrollView(_ contentScrollView: UIScrollView) {
        guard contentScrollView != self.contentScrollView else {
            return
        }

        contentScrollViewObservation?.invalidate()
        containerScrollViewObservation?.invalidate()
        presentedScrollView.contentScrollView = contentScrollView

        let threshold: CGFloat = 0
        var shouldBypass = false

        contentScrollViewObservation = contentScrollView.observe(
            \.contentOffset,
            options: [.old, .new],
            changeHandler: { [unowned self] contentScrollView, change in
                if shouldBypass
                    || ((self.presentedScrollView.isDragging || self.presentedScrollView.isDecelerating)
                    && contentScrollView.contentOffset.y > 0) {
                    return
                }

                guard let oldValue = change.oldValue, let newValue = change.newValue else {
                    return
                }

                let oldY = oldValue.y
                var newY = newValue.y

                if self.isContentScrollViewScrollingToTop {
                    shouldBypass = true
                    contentScrollView.setContentOffset(.zero, animated: true)
                    shouldBypass = false
                    newY = 0
                }

                var finalDeltaY: CGFloat = 0
                if oldY != newY {
                    if newY > oldY {
                        if self.presentedScrollView.contentOffset.y < threshold {
                            let distanceToThreshold = threshold - self.presentedScrollView.contentOffset.y
                            finalDeltaY = max(0, newY - oldY - distanceToThreshold)
                            self.presentedScrollView.contentOffset = CGPoint(x: self.presentedScrollView.contentOffset.x, y: self.presentedScrollView.contentOffset.y + newY - oldY - finalDeltaY)
                            shouldBypass = true
                            let inset = UIEdgeInsets(top: min(threshold, self.presentedScrollView.contentOffset.y),
                                                     left: contentScrollView.contentInset.left,
                                                     bottom: contentScrollView.contentInset.bottom,
                                                     right: contentScrollView.contentInset.right)
                            contentScrollView.contentInset = inset
                            self.contentScrollView?.contentOffset = CGPoint(x: 0, y: oldY)
                            shouldBypass = false
                        }
                    } else {
                        if newY < 0 {
                            self.presentedScrollView.contentOffset = CGPoint(x: self.presentedScrollView.contentOffset.x,
                                                                             y: self.presentedScrollView.contentOffset.y + newY)
                            shouldBypass = true
                            let inset = UIEdgeInsets(top: self.presentedScrollView.contentOffset.y,
                                                     left: contentScrollView.contentInset.left,
                                                     bottom: contentScrollView.contentInset.bottom,
                                                     right: contentScrollView.contentInset.right)
                            contentScrollView.contentInset = inset
                            self.contentScrollView?.contentOffset = CGPoint(x: 0, y: 0)
                            shouldBypass = false
                        }
                    }

                    if self.presentedViewController.isBeingDismissed {
                        contentScrollView.contentInset = .zero
                    }
                    contentScrollView.scrollIndicatorInsets = contentScrollView.contentInset
                }
            })
    }
}

extension ModalPresentationController: UIScrollViewDelegate {
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

extension ModalPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == tapGestureRecognizer else {
            return false
        }

        return gestureRecognizer.location(in: presentedScrollView).y < contentView.frame.minY
    }
}

extension ModalPresentationController {
    fileprivate class PresentedScrollView: UIScrollView {
        weak var presentationController: ModalPresentationController?
        var contentScrollView: UIScrollView?

        override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let contentScrollView = contentScrollView, contentScrollView.isScrollEnabled == true else {
                return super.gestureRecognizerShouldBegin(gestureRecognizer)
            }

            if gestureRecognizer == panGestureRecognizer {
                let inContentScrollView = contentScrollView.frame.contains(panGestureRecognizer.location(in: contentScrollView.superview!))
                if inContentScrollView {
                    return contentScrollView.contentSize.height + contentScrollView.contentInset.top + contentScrollView.contentInset.bottom <= contentScrollView.frame.size.height
                }
            }
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
    }
}

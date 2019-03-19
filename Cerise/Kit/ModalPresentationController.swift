//
//  ModalPresentationController.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/19.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

final class ModalPresentationController: UIPresentationController {

    var maximumContentHeight = ceil(UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height)
    var minimumContentHeight = ceil(UIScreen.main.bounds.height / 5 * 3)
    var dismissalOffsetThreshold: CGFloat = -20

    private lazy var scrollView: ScrollView = {
        let scrollView = ScrollView()
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
        let v = UIView()
        v.layer.cornerRadius = 20
        v.layer.masksToBounds = true
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    lazy var bottomView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black
        return v
    }()

    let handleView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        v.bounds = CGRect(x: 0, y: 0, width: 36, height: 5)
        v.layer.cornerRadius = 2.5
        return v
    }()

    lazy var dimmingView: UIView = {
        let dv = UIView()
        dv.backgroundColor = UIColor.black.withAlphaComponent(0.43)
        return dv
    }()

    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDimmingViewTap(_:)))
        tapGestureRecognizer.delegate = self
        return tapGestureRecognizer
    }()

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override var presentedView: UIView? {
        return scrollView
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        return self.containerView!.bounds
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView else {return}
        let haptic = UISelectionFeedbackGenerator()
        haptic.prepare()
        haptic.selectionChanged()
        scrollView.addSubview(contentView)
        contentView.addSubview(presentedViewController.view)
        presentedViewController.view.layer.cornerRadius = contentView.layer.cornerRadius
        presentedViewController.view.layer.masksToBounds = true
        presentedViewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedViewController.view.frame = contentView.bounds
        scrollView.addSubview(bottomView)
        presentedViewController.view.addSubview(handleView)
        handleView.layer.zPosition = 100
        containerView.layoutIfNeeded()

        containerView.addSubview(dimmingView)
        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = 1
        }, completion: nil)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = 0
        }, completion: nil)
        presentedViewController.view.bringSubviewToFront(handleView)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
    }

    override func containerViewDidLayoutSubviews() {
        scrollView.frame = containerView!.bounds
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height + maximumContentHeight - minimumContentHeight)
        contentView.frame = CGRect(x: 0, y: scrollView.contentSize.height - maximumContentHeight, width: scrollView.frame.width, height: maximumContentHeight)
        bottomView.frame = CGRect(x: 0, y: contentView.frame.maxY, width: scrollView.frame.width, height: scrollView.frame.height)
        handleView.center = CGPoint(x: contentView.bounds.width/2, y: 6 + handleView.bounds.height/2)
    }

    @objc
    func handleDimmingViewTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        dismiss()
    }

    private func dismiss() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    var offsetObservation: NSKeyValueObservation?
    var contentScrollViewObservation: NSKeyValueObservation?
    var containerScrollViewObservation: NSKeyValueObservation?
    var contentScrollView: UIScrollView?

    func contentScrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offsetThreshold = -(maximumContentHeight - minimumContentHeight)/2
        if self.scrollView.contentOffset.y < dismissalOffsetThreshold || (velocity.y < -10 && targetContentOffset.pointee.y <= offsetThreshold * 2) {
            dismiss()
            return
        }
    }

    func contentScrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
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
        if targetContentOffset.pointee.y > scrollView.contentOffset.y {
            isScrollingUp = true
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DispatchQueue.main.async {
            self.isScrollingUp = false
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    }
}

extension ModalPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapGestureRecognizer {
            if gestureRecognizer.location(in: scrollView).y < contentView.frame.minY {
                return true
            }
        }
        return false
    }
}

extension ModalPresentationController {
    fileprivate class ScrollView: UIScrollView {
        weak var presentationController: ModalPresentationController!
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


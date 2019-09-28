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

    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8)
    var dismissOnTapped: Bool = false

    var attemptToDismiss = PublishRelay<Void>()

    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.0
        return view
    }()

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView,
            let presentedView = presentedView else {
            return
        }

        // Add the dimming view and the presented view to the heirarchy.
        presentedView.layer.cornerRadius = TraitEnvironment().corner == .rounded ? 40 : 16
        presentedView.layer.masksToBounds = true
//        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        containerView.addSubview(dimmingView)
        containerView.addSubview(presentedView)

        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { _ -> Void in
            self.dimmingView.alpha = 0.5
        }, completion: { _ -> Void in
            self.dimmingView.alpha = 0.5
        })

        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDimmingView(_:))))
    }

    override public var shouldPresentInFullscreen: Bool {
        return true
    }

    override public var shouldRemovePresentersView: Bool {
        return false
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

    // MARK: -

    override public var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return CGRect.zero
        }

        let containerBounds = containerView.bounds
        let size = self.size(forChildContentContainer: presentedViewController,
                             withParentContainerSize: containerBounds.size)

        assert(containerBounds.width - contentInset.left - contentInset.right == size.width,
               "invalid content size")

        return CGRect(x: contentInset.left,
                      y: containerBounds.height - size.height - contentInset.bottom,
                      width: containerBounds.width - contentInset.left - contentInset.right,
                      height: size.height)
    }

    override public func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return presentedViewController.preferredContentSize
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        guard let containerView = containerView else {
            return
        }

        coordinator.animate(alongsideTransition: { _ -> Void in
            self.dimmingView.frame = containerView.bounds
            self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        }, completion: nil)
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

//
//  CherryTransitionController.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/21.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

@objc
protocol CherryTransitioning: NSObjectProtocol {
    @objc
    optional var anchorView: UIView? { get }

    @objc
    optional func transitionController(_ transitionController: CherryTransitionController,
                                       willTransitionFrom fromViewController: UIViewController,
                                       to toViewController: UIViewController)

    @objc
    optional func transitionController(_ transitionController: CherryTransitionController,
                                       didTransitionFrom fromViewController: UIViewController,
                                       to toViewController: UIViewController)

    @objc
    optional func animateAlongsideTransitionController(_ transitionController: CherryTransitionController,
                                                       from fromViewController: UIViewController,
                                                       to toViewController: UIViewController)

    @objc
    optional func transitionControllerWillCancelTransition(_ transitionController: CherryTransitionController,
                                                           from fromViewController: UIViewController,
                                                           to toViewController: UIViewController)

    @objc
    optional func transitionControllerDidCancelTransition(_ transitionController: CherryTransitionController,
                                                          from fromViewController: UIViewController,
                                                          to toViewController: UIViewController)
}

final class CherryTransitionController: NSObject {
    enum Operation: Int {
        case forward
        case backward
    }

    private let duration: TimeInterval
    private let operation: Operation

    private var mainAnimator: UIViewPropertyAnimator

    init(duration: TimeInterval = 0.35, operation: Operation) {
        self.duration = duration
        self.operation = operation
        let dampingRatio: CGFloat = (operation == .forward) ? 1 : 0.8
        self.mainAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: dampingRatio, animations: nil)
        super.init()
    }
}

extension CherryTransitionController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromViewController = transitionContext.viewController(forKey: .from)?.cerise.cherryTransitioning(),
            let toViewController = transitionContext.viewController(forKey: .to)?.cerise.cherryTransitioning() else {
            return
        }

        switch operation {
        case .forward:
            forwardTransition(using: transitionContext)
        case .backward:
            backwardTransition(using: transitionContext)
        }

        fromViewController.transitionController?(self, willTransitionFrom: fromViewController, to: toViewController)
        toViewController.transitionController?(self, willTransitionFrom: fromViewController, to: toViewController)

        mainAnimator.startAnimation()
        containerView.isUserInteractionEnabled = true
    }

    private func rect(of anchorView: UIView, in containerView: UIView) -> CGRect {
        return anchorView.convert(anchorView.bounds, to: containerView)
    }

    private func forwardTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromViewController = transitionContext.viewController(forKey: .from)?.cerise.cherryTransitioning(),
            let toViewController = transitionContext.viewController(forKey: .to)?.cerise.cherryTransitioning() else {
            return
        }

        let anchor = fromViewController.anchorView.flatMap { $0 }
        guard let anchorView = anchor,
            let transitionView = transitionContext.view(forKey: .from)?.snapshotView(afterScreenUpdates: true) else {
            return
        }

        let anchorRect = rect(of: anchorView, in: containerView)
        let finalFrame = transitionContext.finalFrame(for: toViewController)

        let backgroundView = UIView()
        backgroundView.frame = containerView.bounds
        backgroundView.backgroundColor = .black
        containerView.addSubview(backgroundView)

        let scale = finalFrame.height / anchorRect.height / 4
        transitionView.layer.anchorPoint = CGPoint(x: anchorRect.midX / finalFrame.width,
                                                   y: anchorRect.midY / finalFrame.height)
        transitionView.frame = finalFrame
        transitionView.alpha = 0.92
        containerView.addSubview(transitionView)

        let toMaskView = UIView()
        toMaskView.alpha = 0.0
        toMaskView.clipsToBounds = true
        toMaskView.frame = anchorRect
        containerView.addSubview(toMaskView)

        toMaskView.addSubview(toViewController.view)
        toViewController.view.bounds = CGRect(origin: .zero, size: finalFrame.size)
        toViewController.view.frame.origin.y = -anchorRect.height * 2
        toViewController.view.layoutIfNeeded()

        mainAnimator.isUserInteractionEnabled = true
        mainAnimator.addAnimations {
            toMaskView.alpha = 1.0
            toMaskView.frame = finalFrame
            toViewController.view.frame = finalFrame
            transitionView.alpha = 0.0
            transitionView.transform = CGAffineTransform(scaleX: scale, y: scale)

            fromViewController.animateAlongsideTransitionController?(self, from: fromViewController, to: toViewController)
            toViewController.animateAlongsideTransitionController?(self, from: fromViewController, to: toViewController)
        }

        mainAnimator.addCompletion { _ in
            toMaskView.removeFromSuperview()
            transitionView.removeFromSuperview()
            backgroundView.removeFromSuperview()

            let completed = !transitionContext.transitionWasCancelled
            if completed {
                containerView.addSubview(toViewController.view)
                transitionContext.completeTransition(completed)

                fromViewController.transitionController?(self, didTransitionFrom: fromViewController, to: toViewController)
                toViewController.transitionController?(self, didTransitionFrom: fromViewController, to: toViewController)
            } else {
                transitionContext.completeTransition(completed)

                fromViewController.transitionControllerDidCancelTransition?(self, from: fromViewController, to: toViewController)
                toViewController.transitionControllerDidCancelTransition?(self, from: fromViewController, to: toViewController)
            }
        }
    }

    private func backwardTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromViewController = transitionContext.viewController(forKey: .from)?.cerise.cherryTransitioning(),
            let toViewController = transitionContext.viewController(forKey: .to)?.cerise.cherryTransitioning(),
            let toView = transitionContext.view(forKey: .to) else {
            return
        }

        let anchor = toViewController.anchorView.flatMap { $0 }
        guard let anchorView = anchor,
            let fromView = fromViewController.view.snapshotView(afterScreenUpdates: false),
            let transitionView = toView.snapshotView(afterScreenUpdates: true) else {
            return
        }

        let backgroundView = UIView()
        backgroundView.frame = containerView.bounds
        backgroundView.backgroundColor = .black
        containerView.addSubview(backgroundView)

        let anchorRect = rect(of: anchorView, in: containerView)
        let initialFrame = transitionContext.initialFrame(for: fromViewController)
        let finalFrame = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
        let scale = finalFrame.height / anchorRect.height / 4
        transitionView.layer.anchorPoint = CGPoint(x: anchorRect.midX / finalFrame.width,
                                                   y: anchorRect.midY / finalFrame.height)
        transitionView.frame = initialFrame
        transitionView.alpha = 0.1
        transitionView.transform = CGAffineTransform(scaleX: scale, y: scale)
        containerView.addSubview(transitionView)

        let fromMaskView = UIView()
        fromMaskView.backgroundColor = .red
        fromMaskView.clipsToBounds = true
        fromMaskView.frame = initialFrame
        containerView.addSubview(fromMaskView)

        fromView.frame = initialFrame
        fromMaskView.addSubview(fromView)
        fromViewController.view.removeFromSuperview()

        containerView.addSubview(toView)
        containerView.sendSubviewToBack(toView)

        mainAnimator.addAnimations {
            fromMaskView.alpha = 0
            fromMaskView.frame = anchorRect
            fromView.frame.origin.y = -anchorRect.height * 2
            toView.frame = finalFrame
            transitionView.alpha = 1.0
            transitionView.transform = .identity
        }

        mainAnimator.addCompletion { _ in
            fromView.removeFromSuperview()
            fromMaskView.removeFromSuperview()
            transitionView.removeFromSuperview()
            backgroundView.removeFromSuperview()

            let completed = !transitionContext.transitionWasCancelled
            transitionContext.completeTransition(completed)

            if completed {
                fromViewController.transitionController?(self, didTransitionFrom: fromViewController, to: toViewController)
                toViewController.transitionController?(self, didTransitionFrom: fromViewController, to: toViewController)
            } else {
                fromViewController.transitionControllerDidCancelTransition?(self, from: fromViewController, to: toViewController)
                toViewController.transitionControllerDidCancelTransition?(self, from: fromViewController, to: toViewController)
            }
        }
    }
}

/*
protocol CherryRepresentation: UIViewControllerTransitioningDelegate {
}

extension CherryRepresentation where Self: UIViewController & CherryTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CherryTransitionController(duration: 0.35, operation: .forward)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CherryTransitionController(duration: 0.25, operation: .backward)
    }
}

extension UIViewController: CherryRepresentation where Self: CherryTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CherryTransitionController(duration: 0.35, operation: .forward)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CherryTransitionController(duration: 0.25, operation: .backward)
    }
}
*/

extension Cerise where Base: UIViewController {
    static func cherryTransitioning(root: UIViewController) -> (UIViewController & CherryTransitioning)? {
        if let vc = root as? UIViewController & CherryTransitioning {
            return vc
        }

        for children in root.children {
            if let vc = cherryTransitioning(root: children) {
                return vc
            }
        }

        return nil
    }

    func cherryTransitioning() -> (UIViewController & CherryTransitioning)? {
        return UIViewController.cerise.cherryTransitioning(root: base)
    }
}

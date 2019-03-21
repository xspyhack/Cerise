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
        guard let anchorView = anchor else {
            return
        }

        let anchorRect = rect(of: anchorView, in: containerView)
        let toView = UIView()
        toView.clipsToBounds = true
        toView.frame = anchorRect
        containerView.addSubview(toView)

        toView.addSubview(toViewController.view)
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        toViewController.view.bounds = CGRect(origin: .zero, size: finalFrame.size)
        toViewController.view.frame.origin.y = -toView.frame.minY
        toViewController.view.layoutIfNeeded()

        mainAnimator.isUserInteractionEnabled = true
        mainAnimator.addAnimations {
            toView.frame = finalFrame
            toViewController.view.frame = finalFrame

            fromViewController.animateAlongsideTransitionController?(self, from: fromViewController, to: toViewController)
            toViewController.animateAlongsideTransitionController?(self, from: fromViewController, to: toViewController)
        }

        mainAnimator.addCompletion { _ in
            toView.removeFromSuperview()
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
        guard let anchorView = anchor else {
            return
        }

        let anchorRect = rect(of: anchorView, in: containerView)
        let fromView = UIView()
        fromView.clipsToBounds = true
        fromView.frame = fromViewController.view.frame
        containerView.addSubview(fromView)
        fromViewController.view.removeFromSuperview()
        fromView.addSubview(fromViewController.view)

        let finalFrame = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
        containerView.addSubview(toView)
        containerView.sendSubviewToBack(toView)

        mainAnimator.addAnimations {
            fromView.frame = anchorRect
            fromViewController.view.frame.origin.y = -anchorRect.minY
            toView.frame = finalFrame
            toView.transform = .identity
        }

        mainAnimator.addCompletion { _ in
            fromView.removeFromSuperview()

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

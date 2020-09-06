//
//  ImageDetailTransition.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/28/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit


private let animationDuration: TimeInterval = 0.3

// MARK: Transitioning

class ImageDetailTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var shouldDoInteractive = true
    var interactionTransition = UIPercentDrivenInteractiveTransition()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ImageDetailTransitionPresent()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ImageDetailTransitionDismiss()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return shouldDoInteractive ? interactionTransition : nil
    }
}

// MARK: Present

class ImageDetailTransitionPresent: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        
        let fadeView = UIView(frame: toVC.view.frame)
        fadeView.backgroundColor = .gray
        fadeView.alpha = 0
        
        containerView.addSubview(fadeView)
        containerView.addSubview(toVC.view)
        let toRectSize = toVC.view.frame.size
        
        toVC.view.transform = .init(translationX: 0, y: toRectSize.height)
        toVC.view.layer.cornerRadius = 40
        
        UIView.animate(withDuration: 1.5*animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.2, options: .allowUserInteraction, animations: {
            toVC.view.transform = .identity
            toVC.view.layer.cornerRadius = 0
            fadeView.alpha = 1
        }) { (success) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

// MARK: Dismiss

class ImageDetailTransitionDismiss: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        
        let fadeView = UIView(frame: fromVC.view.frame)
        fadeView.backgroundColor = .gray
        
        toVC.view.frame.size = fromVC.view.frame.size
        containerView.addSubview(toVC.view.snapshotView(afterScreenUpdates: true) ?? toVC.view)
        containerView.addSubview(fadeView)
        containerView.addSubview(fromVC.view)
        
        let toRectSize = fromVC.view.frame.size
        
        let transform = CGAffineTransform(translationX: 0, y: toRectSize.height)
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.2, options: .allowUserInteraction, animations: {
            fromVC.view.transform = transform
            fromVC.view.layer.cornerRadius = 40
            fadeView.alpha = 0
        }) { (success) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

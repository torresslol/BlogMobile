//
//  CardPresentationController.swift
//  BlogMobile
//
//  Created by yy on 2024/12/29.
//
import UIKit

class CustomPresentationController: UIPresentationController {
    private let blurView: UIVisualEffectView
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        let blurEffect = UIBlurEffect(style: .dark)
        blurView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        blurView.alpha = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        blurView.addGestureRecognizer(tapGesture)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        blurView.frame = containerView.bounds
        containerView.insertSubview(blurView, at: 0)
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            blurView.alpha = 1
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.blurView.alpha = 0.5
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            blurView.alpha = 0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.blurView.alpha = 0
        })
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true)
    }
}

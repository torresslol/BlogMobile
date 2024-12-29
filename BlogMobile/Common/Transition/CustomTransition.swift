//
//  CustomTransition.swift
//  BlogMobile
//
//  Created by yy on 2024/12/29.
//

import UIKit

class CustomTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    enum TransitionType {
        case present
        case dismiss
    }
    
    private let type: TransitionType
    private let fromCardFrame: CGRect
    private let configuration: CardTransitionConfiguration
    
    // MARK: - Initialization
    
    init(type: TransitionType, fromCardFrame: CGRect, configuration: CardTransitionConfiguration) {
        self.type = type
        self.fromCardFrame = fromCardFrame
        self.configuration = configuration
        super.init()
    }
    
    // MARK: - Transition Duration
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return configuration.animationDuration
    }
    
    // MARK: - Animation Transition
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        switch type {
        case .present:
            handlePresentation(fromVC: fromVC,
                             toVC: toVC,
                             containerView: containerView,
                             transitionContext: transitionContext)
        case .dismiss:
            handleDismissal(fromVC: fromVC,
                          toVC: toVC,
                          containerView: containerView,
                          transitionContext: transitionContext)
        }
    }
    
    // MARK: - Presentation Handling
    
    private func handlePresentation(fromVC: UIViewController,
                                  toVC: UIViewController,
                                  containerView: UIView,
                                  transitionContext: UIViewControllerContextTransitioning) {
        containerView.addSubview(toVC.view)
        
        let finalFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = fromCardFrame
        
        UIView.animate(withDuration: configuration.animationDuration,
                      delay: 0,
                      usingSpringWithDamping: configuration.springDamping,
                      initialSpringVelocity: configuration.springVelocity,
                      options: .curveEaseOut,
                      animations: {
            toVC.view.frame = finalFrame
        }) { completed in
            transitionContext.completeTransition(completed)
        }
    }
    
    // MARK: - Dismissal Handling
    
    private func handleDismissal(fromVC: UIViewController,
                               toVC: UIViewController,
                               containerView: UIView,
                               transitionContext: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: configuration.animationDuration,
                      delay: 0,
                      usingSpringWithDamping: configuration.springDamping,
                      initialSpringVelocity: configuration.springVelocity,
                      options: .curveEaseOut,
                      animations: {
            fromVC.view.frame = self.fromCardFrame
        }) { completed in
            fromVC.view.removeFromSuperview()
            transitionContext.completeTransition(completed)
        }
    }
}

struct CardTransitionConfiguration {
    let animationDuration: TimeInterval
    let springDamping: CGFloat
    let springVelocity: CGFloat
    
    static let `default` = CardTransitionConfiguration(
        animationDuration: 0.6,
        springDamping: 0.7,
        springVelocity: 0.0
    )
}

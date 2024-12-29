//
//  CardTransitionDelegate.swift
//  BlogMobile
//
//  Created by yy on 2024/12/29.
//

import UIKit

class CustomTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let fromCardFrame: CGRect
    private let configuration: CardTransitionConfiguration

    // MARK: - Initialization

    init(fromCardFrame: CGRect,
         configuration: CardTransitionConfiguration = .default) {
        self.fromCardFrame = fromCardFrame
        self.configuration = configuration
        super.init()
    }

    // MARK: - Transitioning Delegate Methods

    func presentationController(forPresented presented: UIViewController,
                              presenting: UIViewController?,
                              source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitionAnimator(type: .present,
                                    fromCardFrame: fromCardFrame,
                                    configuration: configuration)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitionAnimator(type: .dismiss,
                                    fromCardFrame: fromCardFrame,
                                    configuration: configuration)
    }
}

//
//  PageTabBarController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/24/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PageTabBarController: UITabBarController {

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        let swipeRight = UISwipeGestureRecognizer()
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        swipeRight.rx.event
            .subscribe(onNext: { [weak self] (recognizer) in
                
                if let self = self {
                    guard self.selectedIndex - 1 >= 0 else { return }
                    if let vc = self.viewControllers?[self.selectedIndex - 1] {
                        _ = self.tabBarController(self, shouldSelect: vc)
                    }
                }
                
            }).disposed(by: disposeBag)
        
        let swipeLeft = UISwipeGestureRecognizer()
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        swipeLeft.rx.event
            .subscribe(onNext: { [weak self] (recognizer) in
                if let self = self {
                    guard self.selectedIndex + 1 < self.viewControllers?.count ?? 0 else { return }
                    if let vc = self.viewControllers?[self.selectedIndex + 1] {
                        _ = self.tabBarController(self, shouldSelect: vc)
                    }
                }
            }).disposed(by: disposeBag)
    }
}

extension PageTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let fromView = tabBarController.selectedViewController?.view,
            let toView = viewController.view, fromView != toView,
            let controllerIndex = self.viewControllers?.firstIndex(of: viewController) {

            tabBarController.view.backgroundColor = .white

            let viewSize = fromView.frame
            let scrollRight = controllerIndex > tabBarController.selectedIndex

            // Avoid UI issues when switching tabs fast
            if fromView.superview?.subviews.contains(toView) == true { return false }

            fromView.superview?.addSubview(toView)

            let screenWidth = UIScreen.main.bounds.size.width
            toView.frame = CGRect(x: (scrollRight ? screenWidth : -screenWidth), y: viewSize.origin.y, width: screenWidth, height: viewSize.size.height)

            UIView.animate(withDuration: 0.25, delay: TimeInterval(0.0), options: [.curveEaseOut, .preferredFramesPerSecond60], animations: {
                fromView.frame = CGRect(x: (scrollRight ? -screenWidth : screenWidth), y: viewSize.origin.y, width: screenWidth, height: viewSize.size.height)
                toView.frame = CGRect(x: 0, y: viewSize.origin.y, width: screenWidth, height: viewSize.size.height)
            }, completion: { finished in
                if finished {
                    fromView.removeFromSuperview()
                    tabBarController.selectedIndex = controllerIndex
                }
            })
            return true
        }
        return false
    }
    
}

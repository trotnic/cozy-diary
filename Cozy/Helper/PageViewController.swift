//
//  PageViewController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/19/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {

    var items: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        view.backgroundColor = .white
        decoratePageControl()
    }
    
    fileprivate func decoratePageControl() {
        let pc = UIPageControl.appearance(whenContainedInInstancesOf: [PageViewController.self])
        pc.currentPageIndicatorTintColor = .black
        pc.pageIndicatorTintColor = .lightGray
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let indexOfAfter = items.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = indexOfAfter + 1
        guard nextIndex != items.count else {
            return nil
        }
        guard items.count > nextIndex else {
            return nil
        }
        
        return items[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let indexOfBefore = items.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = indexOfBefore - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard items.count > previousIndex else {
            return nil
        }
        
        return items[previousIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return items.count
    }
    
    func presentationIndex(for _: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = items.firstIndex(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
}

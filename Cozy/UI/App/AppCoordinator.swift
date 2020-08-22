//
//  AppCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/20/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator {
    func start()
}

protocol ParentCoordinator: Coordinator {
    var childCoordinators: [Coordinator] { get }
}

class AppCoordinator: ParentCoordinator {
    
    let window: UIWindow
    var childCoordinators: [Coordinator] = []
    var pageViewController: PageViewController!
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        pageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        
        let createCoordinator = MemoryCreateCoordinator()
        childCoordinators.append(createCoordinator)
        createCoordinator.start()
        
        let collectionCoordinator = MemoryCollectionCoordinator()
        childCoordinators.append(collectionCoordinator)
        collectionCoordinator.start()
        
        pageViewController.items = [
            createCoordinator.navigationController,
            collectionCoordinator.viewController
        ]
        
        pageViewController.setViewControllers([createCoordinator.navigationController], direction: .forward, animated: true)
        
        window.rootViewController = pageViewController
        window.makeKeyAndVisible()
    }
    
}

//
//  AppCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/20/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import UIKit


protocol Coordinator: class {
    func start()
}

protocol ParentCoordinator: Coordinator {
    var childCoordinators: [Coordinator] { get }
}

class AppCoordinator: ParentCoordinator {
        
    let window: UIWindow
    var childCoordinators: [Coordinator] = []
    var tabBarController: NMTabBarController!
    
    let memoryStore: MemoryStoreType
    
    init(window: UIWindow) {
        self.window = window
        memoryStore = Synchronizer(calendar: PerfectCalendar())
    }
    
    func start() {
        tabBarController = NMTabBarController()
        
        let wrapController = NMNavigationController()
        
        wrapController.tabBarItem = UITabBarItem(title: "Today", image: UIImage(systemName: "tortoise"), tag: 0)

        let memoryEditCoordinator = MemoryEditCoordinator(
            memory: memoryStore.relevantMemory.value,
            memoryStore: memoryStore,
            navigationController: wrapController)

        childCoordinators.append(memoryEditCoordinator)
        memoryEditCoordinator.start()
        wrapController.setViewControllers([memoryEditCoordinator.viewController], animated: true)

        let memoryCollectionCoordinator = MemoryCollectionCoordinator(memoryStore: memoryStore)


        childCoordinators.append(memoryCollectionCoordinator)
        memoryCollectionCoordinator.start()
        memoryCollectionCoordinator.navigationController.tabBarItem = UITabBarItem(title: "Previous", image: UIImage(systemName: "flame"), tag: 1)

        tabBarController.viewControllers = [
            memoryEditCoordinator.navigationController,
            memoryCollectionCoordinator.navigationController
        ]
//        let coordinator = UnsplashImageCollectionCoordinator()
//        childCoordinators.append(coordinator)
//        coordinator.start()
//
//        wrapController.setViewControllers([coordinator.viewController], animated: true)
//
//        tabBarController.viewControllers = [wrapController]
        tabBarController.selectedIndex = 1
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
    }
    
}

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
        let currentMemoryCoordinator = CurrentMemoryEditCoordinator(memoryStore: memoryStore, navigationController: wrapController)
        childCoordinators.append(currentMemoryCoordinator)
        currentMemoryCoordinator.start()

        
        let memoryCollectionCoordinator = MemoryCollectionCoordinator(memoryStore: memoryStore)
        childCoordinators.append(memoryCollectionCoordinator)
        memoryCollectionCoordinator.start()
        memoryCollectionCoordinator.navigationController.tabBarItem = UITabBarItem(title: "Previous", image: UIImage(systemName: "flame"), tag: 1)

        tabBarController.viewControllers = [
            currentMemoryCoordinator.navigationController,
            memoryCollectionCoordinator.navigationController
        ]
        
        tabBarController.selectedIndex = 0
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
}

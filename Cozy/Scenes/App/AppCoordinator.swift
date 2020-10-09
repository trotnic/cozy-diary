//
//  AppCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/20/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import UIKit


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
        
        wrapController.tabBarItem = UITabBarItem(title: "Today", image: UIImage(systemName: "square.and.pencil"), tag: 0)
        let currentMemoryCoordinator = CurrentMemoryEditCoordinator(memoryStore: memoryStore, navigationController: wrapController)
        
        childCoordinators.append(currentMemoryCoordinator)
        currentMemoryCoordinator.start()

        
        let memoryCollectionCoordinator = MemoryCollectionCoordinator(memoryStore: memoryStore)
        childCoordinators.append(memoryCollectionCoordinator)
        memoryCollectionCoordinator.start()
        
        let collectionItem = UITabBarItem(title: "Previous", image: UIImage(systemName: "calendar"), tag: 1)
        memoryCollectionCoordinator.navigationController.tabBarItem = collectionItem

        tabBarController.viewControllers = [
            currentMemoryCoordinator.navigationController,
            memoryCollectionCoordinator.navigationController
        ]
        
        tabBarController.selectedIndex = 1
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
}

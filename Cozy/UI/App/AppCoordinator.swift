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
    var tabBarController: UITabBarController!
    
    let memoryStore: MemoryStoreType
    
    init(window: UIWindow) {
        self.window = window
        
        memoryStore = Synchronizer(calendar: PerfectCalendar())
    }
    
    func start() {
        
        tabBarController = PageTabBarController()
        
        let createCoordinator = MemoryCreateCoordinator(memoryStore: memoryStore)
        childCoordinators.append(createCoordinator)
        createCoordinator.navigationController.tabBarItem = .init(title: "Today", image: UIImage(systemName: "pencil"), tag: 0)
        createCoordinator.start()
        
        let collectionCoordinator = MemoryCollectionCoordinator(memoryStore: memoryStore)
        childCoordinators.append(collectionCoordinator)
        collectionCoordinator.navigationController.tabBarItem = .init(title: "All memories", image: UIImage(systemName: "tray"), tag: 1)
        collectionCoordinator.start()
        
        tabBarController.viewControllers = [
            createCoordinator.navigationController,
            collectionCoordinator.navigationController
        ]
        
        tabBarController.selectedIndex = 1
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
}

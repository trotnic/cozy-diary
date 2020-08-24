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
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        
        tabBarController = PageTabBarController()
        
        let createCoordinator = MemoryCreateCoordinator()
        childCoordinators.append(createCoordinator)
        createCoordinator.navigationController.tabBarItem = .init(title: "Today", image: UIImage(systemName: "pencil"), tag: 0)
        createCoordinator.start()
        
        let collectionCoordinator = MemoryCollectionCoordinator()
        childCoordinators.append(collectionCoordinator)
        collectionCoordinator.navigationController.tabBarItem = .init(title: "All memories", image: UIImage(systemName: "tray"), tag: 1)
        collectionCoordinator.start()
        
        tabBarController.viewControllers = [
            createCoordinator.navigationController,
            collectionCoordinator.navigationController
        ]
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
}

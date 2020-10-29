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
    
    let memoryStore: MemoryStoreType
    
    init(window: UIWindow) {
        self.window = window
        memoryStore = PlainMemoryStorage(accessor: .init(manager: CoreDataManager()), calendar: PerfectCalendar())
    }
    
    func start() {
        let memoryCollectionCoordinator = MemoryCollectionCoordinator(memoryStore: memoryStore)
        childCoordinators.append(memoryCollectionCoordinator)
        memoryCollectionCoordinator.start()
        
        window.rootViewController = memoryCollectionCoordinator.navigationController
        window.makeKeyAndVisible()
    }
    
}

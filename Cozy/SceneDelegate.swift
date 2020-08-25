//
//  SceneDelegate.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/14/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator!
    var taskIdentifier: UIBackgroundTaskIdentifier!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let scene = scene as? UIWindowScene {
            coordinator = .init(window: UIWindow(windowScene: scene))
            coordinator.start()
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
//        taskIdentifier = UIApplication.shared.beginBackgroundTask()
//        CoreMemory.update(Synchronizer.shared.relevantMemory.value)
//        UIApplication.shared.endBackgroundTask(taskIdentifier)
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

}


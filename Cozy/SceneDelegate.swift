//
//  SceneDelegate.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/14/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let scene = scene as? UIWindowScene {    
            let vc = MemoryCreateViewController(MemoryCreateViewModel(memory: Synchronizer.shared.relevantMemory))
            window = UIWindow(windowScene: scene)
            window?.rootViewController = UINavigationController(rootViewController: vc)
            
            window?.makeKeyAndVisible()
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}


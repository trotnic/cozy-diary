//
//  MemoryShowCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/20/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class MemoryShowCoordinator: ParentCoordinator {
    
    var viewController: MemoryCreateViewController!
    let navigationController = UINavigationController()
    var childCoordinators: [Coordinator] = []
    
    private let memory: BehaviorRelay<Memory>
    
    init(memory: Memory) {
        self.memory = .init(value: memory)
    }
    
    func start() {
        
//        let viewModel = MemoryShowViewModel(memory: memory)
        let viewModel = MemoryCreateViewModel(memory: memory)
        viewController = .init(viewModel)
//        navigationController.setViewControllers([viewController], animated: true)
    }
}

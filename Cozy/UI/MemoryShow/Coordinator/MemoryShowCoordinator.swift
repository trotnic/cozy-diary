//
//  MemoryShowCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/20/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation


class MemoryShowCoordinator: Coordinator {
    
    var viewController: MemoryShowViewController!
    
    private let memory: Memory
    
    init(memory: Memory) {
        self.memory = memory
    }
    
    func start() {
        
        let viewModel = MemoryShowViewModel(memory: memory)
        viewController = .init(viewModel: viewModel)
    }
}

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
    var childCoordinators: [Coordinator] = []
    
    private let memory: BehaviorRelay<Memory>
    private let memoryStore: MemoryStoreType
    private let disposeBag = DisposeBag()
    
    
    // MARK: Init
    init(memory: Memory, memoryStore: MemoryStoreType) {
        self.memory = .init(value: memory)
        self.memoryStore = memoryStore
    }
    
    func start() {
        let viewModel = MemoryCreateViewModel(memory: memory, memoryStore: memoryStore)
        viewController = .init(viewModel)
    }
}

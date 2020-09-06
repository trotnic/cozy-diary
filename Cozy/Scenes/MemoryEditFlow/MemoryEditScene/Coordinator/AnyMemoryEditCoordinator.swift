//
//  MemoryEditCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/28/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alertift


class AnyMemoryEditCoordinator: MemoryEditCoordinator {
    
    private let disposeBag = DisposeBag()
    
    override init(memory: BehaviorRelay<Memory>, memoryStore: MemoryStoreType, navigationController: UINavigationController) {
        super.init(memory: memory, memoryStore: memoryStore, navigationController: navigationController)
    }
    
    override func start() {
        let viewModel = MemoryEditViewModel(memory: memory, memoryStore: memoryStore)
        bindToViewModel(viewModel)
        
        viewModel
            .outputs
            .shouldDeleteMemory
            .subscribe(onNext: { [weak self] (_) in
                self?.navigationController.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewController = .init(viewModel)
    }
}


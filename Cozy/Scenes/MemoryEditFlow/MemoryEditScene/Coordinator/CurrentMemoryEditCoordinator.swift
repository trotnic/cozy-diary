//
//  CurrentMemoryEditCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/4/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class CurrentMemoryEditCoordinator: MemoryEditCoordinator {
    
    private let disposeBag = DisposeBag()
    
    convenience init(memoryStore: MemoryStoreType, navigationController: UINavigationController) {
        self.init(memory: memoryStore.relevantMemory, memoryStore: memoryStore, navigationController: navigationController)
    }
    
    override func start() {
        let viewModel = MemoryEditViewModel(memory: memoryStore.relevantMemory, memoryStore: memoryStore)
        bindToViewModel(viewModel)
        
        viewModel
            .outputs
            .shouldDeleteMemory
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                viewModel.provideMemory.accept(self.memoryStore.relevantMemory)
            })
            .disposed(by: disposeBag)
        
        viewController = .init(viewModel)
        navigationController.setViewControllers([viewController], animated: true)
    }
}

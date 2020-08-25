//
//  MemoriesCollectionCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/20/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class MemoryCollectionCoordinator: Coordinator {
    
    var viewController: MemoryCollectionViewController!
    let navigationController = UINavigationController()
    
    var childs: [Coordinator] = []
    
    private let disposeBag = DisposeBag()
    
    let memoryStore: MemoryStoreType
    
    init(memoryStore: MemoryStoreType) {
        self.memoryStore = memoryStore
    }
    
    func start() {
        
        let viewModel = MemoryCollectionViewModel(memoryStore: memoryStore)
        viewController = .init(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: true)
        
        // SELFCOMM: Opens detail for selected memory
        viewModel.outputs.detailRequestObservable
            .subscribe(onNext: { [weak self] memory in
            self?.gotodetail(memory: memory)
        }).disposed(by: disposeBag)
                
        // SELFCOMM: Opens search controller
        viewModel.outputs.searchRequestObservable
            .subscribe(onNext: { [weak self] in
                self?.gotosearch()
            }).disposed(by: disposeBag)
    }
    
    func gotodetail(memory: Memory) {
        let coordinator = MemoryShowCoordinator(memory: memory)
        coordinator.start()
        childs.append(coordinator)
        coordinator.viewController.stubSwipeToRight()
        coordinator.viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(coordinator.viewController, animated: true)
    }
    
    func gotosearch() {
        let coordinator = MemorySearchCoordinator(presentationController: navigationController, memoryStore: memoryStore)
        childs.append(coordinator)
        coordinator.start()
    }
    
}

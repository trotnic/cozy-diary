//
//  MemoryCollectionCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/29/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa



class MemoryCollectionCoordinator: ParentCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    var viewController: MemoryCollectionViewController!
    var navigationController: NMNavigationController!
    
    // MARK: Private
    private let memoryStore: MemoryStoreType
    private let disposeBag = DisposeBag()
    
    // MARK: Init
    init(memoryStore: MemoryStoreType) {
        self.memoryStore = memoryStore
    }
    
    func start() {
        
        let viewModel = MemoryCollectionViewModel(memoryStore: memoryStore)
        viewController = .init(viewModel: viewModel)
        
        navigationController = NMNavigationController(rootViewController: viewController)

        // SELFCOMM: Opens detail for selected memory
        viewModel
            .outputs
            .detailRequestObservable
            .subscribe(onNext: { [weak self] memory in
                self?.gotodetail(memory: memory)
            })
            .disposed(by: disposeBag)
                
        // SELFCOMM: Opens search controller
        viewModel
            .outputs
            .searchRequestObservable
            .subscribe(onNext: { [weak self] in
                self?.gotosearch()
            })
            .disposed(by: disposeBag)
        
        viewModel
            .outputs
            .addRequestObservable
            .bind { [weak self] in
                self?.gotoadd()
            }
            .disposed(by: disposeBag)
        
        // REFACTOR
        viewModel
            .inputs
            .viewWillAppear
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if !self.childCoordinators.isEmpty {
                    self.childCoordinators.removeAll()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func gotodetail(memory: BehaviorRelay<Memory>) {
        let coordinator = AnyMemoryEditCoordinator(
            memory: memory,
            memoryStore: memoryStore,
            navigationController: navigationController
        )
        
        coordinator.start()
        coordinator.viewController.hidesBottomBarWhenPushed = true        
        childCoordinators.append(coordinator)
        
        navigationController.pushViewController(coordinator.viewController, animated: true)
    }
    
    private func gotosearch() {
        let coordinator = MemorySearchCoordinator(presentingController: viewController, memoryStore: memoryStore)
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    private func gotoadd() {
        let viewModel = MemoryAddViewModel(factory: MemoryFactory(store: memoryStore))
        let viewController = MemoryAddController(viewModel: viewModel)
        let wrapper = NMNavigationController(rootViewController: viewController)
        self.viewController.present(wrapper, animated: true)
    }
}


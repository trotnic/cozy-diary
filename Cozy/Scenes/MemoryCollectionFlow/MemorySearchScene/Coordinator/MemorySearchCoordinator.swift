//
//  MemorySearchCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/25/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class MemorySearchCoordinator: ParentCoordinator {
    
    var childCoordinators: [Coordinator] = []
    var viewController: MemorySearchController!
    let presentingController: UIViewController
    var navigationController: UINavigationController!
    
    private let disposeBag = DisposeBag()
    private let memoryStore: MemoryStoreType
    
    init(presentingController: UIViewController, memoryStore: MemoryStoreType) {
        self.presentingController = presentingController
        self.memoryStore = memoryStore
    }
    
    func start() {
        let viewModel = MemorySearchViewModel(memoryStore: memoryStore, filterManager: FilterManager())
        viewController = MemorySearchController(viewModel: viewModel)
        
        navigationController = NMNavigationController()
        navigationController.pushViewController(viewController, animated: true)
        navigationController.modalPresentationStyle = .fullScreen
        
        viewModel.outputs.dismissCurrentController
            .subscribe(onNext: { [weak self] in
                self?.navigationController.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.showDetail
            .subscribe(onNext: { [weak self] (memory) in
                self?.gotodetail(memory: memory)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.showFilter
            .subscribe(onNext: { [weak self] (manager) in
                self?.presentFilterScreen(filterManager: manager)
            })
            .disposed(by: disposeBag)
        
        presentingController.present(navigationController, animated: true)
    }
    
    
    func gotodetail(memory: BehaviorRelay<Memory>) {
        let editCoordinator = AnyMemoryEditCoordinator(memory: memory, memoryStore: memoryStore, navigationController: navigationController)
        childCoordinators.append(editCoordinator)
        editCoordinator.start()
        navigationController.pushViewController(editCoordinator.viewController, animated: true)  
    }
    
    func presentFilterScreen(filterManager: FilterManagerType) {
        let viewModel = MemorySearchFilterViewModel(manager: filterManager)
        let controller = MemorySearchFilterController(viewModel: viewModel)
        
        let wrapController = NMNavigationController(rootViewController: controller)
        
        self.viewController.present(wrapController, animated: true)
    }
    
}

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
        let viewModel = MemorySearchViewModel(memoryStore: memoryStore)
        viewController = MemorySearchController(viewModel: viewModel)
        
        navigationController = NMNavigationController()
        navigationController.pushViewController(viewController, animated: true)
        navigationController.modalPresentationStyle = .overFullScreen
        
        viewModel.outputs.closeObservable
            .subscribe(onNext: { [weak self] in
                self?.navigationController.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.showDetail
            .subscribe(onNext: { [weak self] (memory) in
                self?.gotodetail(memory: memory)
            })
            .disposed(by: disposeBag)

        presentingController.present(navigationController, animated: true)
    }
    
    
    func gotodetail(memory: Memory) {
        let editCoordinator = MemoryEditCoordinator(memory: memory, memoryStore: memoryStore, navigationController: navigationController)
        childCoordinators.append(editCoordinator)
        editCoordinator.start()
        navigationController.pushViewController(editCoordinator.viewController, animated: true)
        
    }
    
}

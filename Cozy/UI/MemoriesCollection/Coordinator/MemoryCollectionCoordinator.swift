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
    
    var childs: [MemoryShowCoordinator] = []
    
    private let disposeBag = DisposeBag()
    
    func start() {
        
        let viewModel = MemoryCollectionViewModel(dataModeller: CoreDataModeller(manager: CoreDataManager.shared))
        viewController = .init(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: true)
        
        viewModel.outputs.detailRequestObservable
            .subscribe(onNext: { [weak self] memory in
            self?.gotodetail(memory: memory)
        }).disposed(by: disposeBag)
        
    }
    
    func gotodetail(memory: Memory) {
        let coordinator = MemoryShowCoordinator(memory: memory)
        coordinator.start()
        childs.append(coordinator)
//        coordinator.navigationController.modalPresentationStyle = .overFullScreen
        
//        coordinator.viewController.modalPresentationStyle = .overFullScreen
//        coordinator.viewController.modalTransitionStyle = .coverVertical
//        coordinator.viewController.definesPresentationContext = true
//        coordinator.viewController.hidesBottomBarWhenPushed
//        coordinator.viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(coordinator.viewController, animated: true)
    }
    
}

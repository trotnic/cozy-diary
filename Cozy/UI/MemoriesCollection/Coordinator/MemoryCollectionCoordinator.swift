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


class MemoryCollectionCoordinator {
    
    var viewController: MemoryCollectionViewController!
    
    var childs: [MemoryShowCoordinator] = []
    
    private let disposeBag = DisposeBag()
    
    func start() {
        
        let viewModel = MemoryCollectionViewModel()
        viewController = .init(viewModel: viewModel)
        viewModel.detailMemoryRequest.subscribe(onNext: { [weak self] memory in
            self?.gotodetail(memory: memory)
        }).disposed(by: disposeBag)
        
    }
    
    func gotodetail(memory: Memory) {
        let coordinator = MemoryShowCoordinator(memory: memory)
        coordinator.start()
        childs.append(coordinator)
        viewController.present(coordinator.viewController, animated: true)
    }
    
}

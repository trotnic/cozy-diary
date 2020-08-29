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
    
    private let disposeBag = DisposeBag()
    private let memoryStore: MemoryStoreType
    
    init(presentingController: UIViewController, memoryStore: MemoryStoreType) {
        self.presentingController = presentingController
        self.memoryStore = memoryStore
    }
    
    func start() {
        let viewModel = MemorySearchViewModel(memoryStore: memoryStore)
        viewController = MemorySearchController(viewModel: viewModel)
        viewController.hidesBottomBarWhenPushed = true
        viewController.stubSwipeToRight()
        
        let wrapper = UINavigationController(rootViewController: viewController)
        wrapper.modalPresentationStyle = .fullScreen
        
        viewModel.outputs.closeObservable
            .subscribe(onNext: {
                wrapper.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        

        presentingController.present(wrapper, animated: true)
    }
    
}

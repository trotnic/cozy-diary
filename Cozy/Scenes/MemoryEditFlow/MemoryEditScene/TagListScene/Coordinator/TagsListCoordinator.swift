//
//  TagsListCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/1/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alertift


class TagsListCoordinator: Coordinator {
    
    let presentingController: UIViewController
    var viewController: TagsListController!
    
    private let disposeBag = DisposeBag()
    private let manager: TagManager
    private let memoryStore: MemoryStoreType
    
    init(presentingController: UIViewController, manager: TagManager, memoryStore: MemoryStoreType) {
        self.presentingController = presentingController
        self.manager = manager
        self.memoryStore = memoryStore
    }
    
    func start() {
        let viewModel = TagsListViewModel(manager: manager, memoryStore: memoryStore)
        
        viewController = .init(viewModel: viewModel)
        
        let wrapController = NMNavigationController()
        wrapController.setViewControllers([viewController], animated: true)
        
        wrapController.modalPresentationStyle = .fullScreen
        
        presentingController.present(wrapController, animated: true)
    }
}

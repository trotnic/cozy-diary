//
//  MemoryCreateCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/19/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class MemoryCreateCoordinator {
    
    var viewController: MemoryCreateViewController!
    var childs: [ImageDetailCoordinator] = []
    
    private let disposeBag = DisposeBag()
    
    func start() {
        
        let viewModel = MemoryCreateViewModel(memory: Synchronizer.shared.relevantMemory)
        viewController = MemoryCreateViewController(viewModel)
        
        
        viewModel.requestDetailImage
            .subscribe(onNext: { [weak self] (image) in
                if let vc = self?.viewController {
                    let coord = ImageDetailCoordinator(vc, image: image)
                    self?.childs.append(coord)                    
                    coord.start()
                }
        }).disposed(by: disposeBag)
    }
    
}

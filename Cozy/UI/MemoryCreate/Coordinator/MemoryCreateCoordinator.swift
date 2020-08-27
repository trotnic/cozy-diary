//
//  MemoryCreateCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/19/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class MemoryCreateCoordinator: ParentCoordinator {
    
    var viewController: MemoryCreateViewController!
    let navigationController = UINavigationController()
    var childCoordinators: [Coordinator] = []
    
    private let disposeBag = DisposeBag()
    
    let memoryStore: MemoryStoreType
    
    init(memoryStore: MemoryStoreType) {
        self.memoryStore = memoryStore
    }
    
    func start() {
        let viewModel = MemoryCreateViewModel(memory: memoryStore.relevantMemory, memoryStore: memoryStore)
        viewController = MemoryCreateViewController(viewModel)        
        
        navigationController.setViewControllers([viewController], animated: false)
        
        // SELFCOMM: Inserting photo via image sheet
        viewModel.outputs.photoInsertRequestObservable
            .subscribe(onNext: { [weak self] (_) in
                if let self = self {
                    
                    let coordinator = ImageProposalCoordinator(presentationController: self.viewController, navigationController: self.navigationController)
                    self.childCoordinators.append(coordinator)
                    
                    coordinator.metaObservable.subscribe(onNext: { [weak self] (meta) in
                        viewModel.inputs.photoInsertResponse(meta)
                        self?.childCoordinators.removeLast()
                    }).disposed(by: self.disposeBag)
                    
                    coordinator.start()
                    
                }
            }).disposed(by: disposeBag)
        
        // SELFCOMM: Transition to image detail
        viewModel.outputs.photoDetailRequestObservable
            .subscribe(onNext: { [weak self] (photo) in
                if let self = self {

                    let coordinator = ImageDetailCoordinator(image: photo)
                    self.childCoordinators.append(coordinator)
                    
                    coordinator.start()
                    self.viewController.present(coordinator.controller, animated: true)
                }
            }).disposed(by: disposeBag)
        
        // SELFCOMM: Activity VC to share selected image
        viewModel.outputs.photoShareRequestObservable
            .subscribe(onNext: { [weak self] (photo) in
            
                DispatchQueue.global(qos: .userInteractive).async {
                    if let image = UIImage(data: photo) {
                        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                        activity.excludedActivityTypes = [.copyToPasteboard]
                        DispatchQueue.main.async {
                            self?.viewController.present(activity, animated: true)
                        }
                    }
                }
            }).disposed(by: disposeBag)
        
        // SELFCOMM: Map
        viewModel.outputs.mapInsertRequestObservable
            .subscribe(onNext: { [weak self] in
                if let vc = self?.navigationController {
                    let coord = MapCreateCoordinator(vc)
                    self?.childCoordinators.append(coord)
                    coord.start()
                }
            }).disposed(by: disposeBag)
        
        // SELFCOMM: Graffiti
        viewModel.outputs.graffitiInsertRequestObservable
            .subscribe(onNext: { [weak self] in
                if let self = self {
                    let vc = self.navigationController
                    let coord = GraffitiCreateCoordinator(vc)
                    
                    coord.outputs.saveObservable
                        .subscribe(onNext: { (graffiti) in
                            viewModel.inputs.graffitiInsertResponse(graffiti)
                            vc.dismiss(animated: true)
                        }).disposed(by: self.disposeBag)
                    
                    coord.outputs.closeObservable
                        .subscribe(onNext: {
                            vc.dismiss(animated: true)
                        }).disposed(by: self.disposeBag)
                    
                    self.childCoordinators.append(coord)
                    coord.start()
                }
            }).disposed(by: disposeBag)
    }
}

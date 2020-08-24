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
    
    func start() {
        let viewModel = MemoryCreateViewModel(memory: Synchronizer.shared.relevantMemory)
        viewController = MemoryCreateViewController(viewModel)
        navigationController.setViewControllers([viewController], animated: false)
        
        // SELFCOMM: Inserting photo via image sheet
        viewModel.outputs.photoInsertRequestObservable
            .subscribe(onNext: { [unowned self] (_) in
            
            let coordinator = ImageProposalCoordinator(presentationController: self.viewController)
            coordinator.start()
            coordinator.metaObservable.subscribe(onNext: { [weak self] (meta) in
                viewModel.inputs.photoInsertResponse(meta)
                self?.childCoordinators.removeAll()
            }).disposed(by: self.disposeBag)
            self.childCoordinators.append(coordinator)
        }).disposed(by: disposeBag)
        
        // SELFCOMM: Transition to detail image
        viewModel.outputs.photoDetailRequestObservable
            .subscribe(onNext: { [weak self] (photo) in
            
            if let vc = self?.navigationController {
                let coord = ImageDetailCoordinator(vc, image: photo)
                self?.childCoordinators.append(coord)
                coord.start()
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
                    
                    self.childCoordinators.append(coord)
                    coord.start()
                }
            }).disposed(by: disposeBag)
    }
}

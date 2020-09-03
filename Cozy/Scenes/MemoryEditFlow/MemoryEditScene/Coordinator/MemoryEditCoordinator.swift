//
//  MemoryEditCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/28/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alertift


class MemoryEditCoordinator: ParentCoordinator {
    
    
    var childCoordinators: [Coordinator] = []
    
    var viewController: MemoryEditViewController!
    let navigationController: UINavigationController
    
    // MARK: Private
    private let memory: BehaviorRelay<Memory>
    private let memoryStore: MemoryStoreType
    
    private let disposeBag = DisposeBag()
    
    private let imagePicker = ImagePicker()
    
    // MARK: Init
    init(memory: BehaviorRelay<Memory>, memoryStore: MemoryStoreType, navigationController: UINavigationController) {
        self.memory = memory
        self.memoryStore = memoryStore
        self.navigationController = navigationController
    }
    
    
}

extension MemoryEditCoordinator {
    
    func start() {
        let viewModel = MemoryEditViewModel(memory: memory, memoryStore: memoryStore)
        
        
        viewModel.outputs.shouldClearStack
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                if !self.childCoordinators.isEmpty {
                    self.childCoordinators.removeAll()
                }
            })
            .disposed(by: disposeBag)
     
        processPhotoDetail(viewModel)
        processPhotoInsert(viewModel)
        processPhotoShare(viewModel)
        processTagAdd(viewModel)
        processGraffitiInsert(viewModel)
        
        viewController = .init(viewModel)
    }
    
    
    // MARK: Convenience methods
    private func processPhotoDetail(_ viewModel: MemoryCreateViewModelType) {
        viewModel.outputs.photoDetailRequestObservable
            .subscribe(onNext: { [weak self] (image) in
                if let self = self {
                    let viewModel = LocalImageDetailViewModel(image: image)
                    let viewController = ImageDetailViewController(viewModel)
                    
                    viewModel.outputs.closeRequestObservable
                        .subscribe(onNext: {
                            viewController.dismiss(animated: true)
                        })
                        .disposed(by: self.disposeBag)
                    
                    viewModel.outputs.moreRequestObservable
                        .subscribe(onNext: {
                            Alertift.actionSheet()
                                .action(.default("Share"))
                                .action(.destructive("Delete"))
                                .action(.cancel("Cancel"))
                                .show(on: viewController)
                            
                        })
                        .disposed(by: self.disposeBag)
                    
                    viewController.modalPresentationStyle = .fullScreen
                    self.viewController.present(viewController, animated: true)
                }
            })
        .disposed(by: disposeBag)
    }
    
    private func processPhotoInsert(_ viewModel: MemoryCreateViewModelType) {
        viewModel.outputs.photoInsertRequestObservable
            .subscribe(onNext: { [weak self] in
                if let self = self {
                    let coordinator = ImageProposalCoordinator(presentingController: self.viewController)
                    
                    coordinator.start()
                    
                    
                    self.childCoordinators.append(coordinator)
                    
                    coordinator.metaObservable
                        .subscribe(onNext: { (meta) in
                            viewModel.inputs.photoInsertResponse(meta)
                        })
                    .disposed(by: self.disposeBag)
                    
                    coordinator.cancelObservable
                        .subscribe(onNext: { _ in
                            self.childCoordinators.removeLast()
                        })
                    .disposed(by: self.disposeBag)

                }
            })
        .disposed(by: disposeBag)
    }
    
    private func processPhotoShare(_ viewModel: MemoryCreateViewModelType) {
        viewModel.outputs.photoShareRequestObservable
            .subscribe(onNext: { [weak self] (data) in
                DispatchQueue.global(qos: .userInteractive).async {
                    if let image = UIImage(data: data) {
                        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                        activity.excludedActivityTypes = [.copyToPasteboard]
                        DispatchQueue.main.async {
                            self?.viewController.present(activity, animated: true)
                        }
                    }
                }
            })
        .disposed(by: disposeBag)
    }
    
    private func processTagAdd(_ viewModel: MemoryCreateViewModelType) {
        viewModel.outputs.tagAddRequestObservable
            .subscribe(onNext: { [weak self] memory in
                if let self = self {
                    let coordinator = TagsListCoordinator(presentingController: self.viewController,
                                                          manager: .init(with: memory),
                                                          memoryStore: self.memoryStore)
                    self.childCoordinators.append(coordinator)
                    coordinator.start()
                }
            })
        .disposed(by: disposeBag)
    }
    
    private func processGraffitiInsert(_ viewModel: MemoryCreateViewModelType) {
        viewModel.outputs.graffitiInsertRequestObservable
            .subscribe(onNext: { [weak self] in
                if let self = self,
                    let vc = self.viewController {
                    
                    let coord = GraffitiCreateCoordinator(vc)
                    
                    coord.outputs.saveObservable
                        .subscribe(onNext: { [weak self] (graffiti) in
                            viewModel.inputs.graffitiInsertResponse(graffiti)
                            vc.dismiss(animated: true)
                            self?.childCoordinators.removeLast()
                        }).disposed(by: self.disposeBag)
                    
                    coord.outputs.closeObservable
                        .subscribe(onNext: { [weak self] in
                            vc.dismiss(animated: true)
                            self?.childCoordinators.removeLast()
                        }).disposed(by: self.disposeBag)
                    
                    self.childCoordinators.append(coord)
                    coord.start()
                }
            })
        .disposed(by: disposeBag)
    }
}

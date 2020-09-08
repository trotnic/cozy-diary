//
//  MemoryEditCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/4/20.
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
    
    let memory: BehaviorRelay<Memory>
    let memoryStore: MemoryStoreType
    private let disposeBag = DisposeBag()
    let imagePicker = ImagePicker()
    
    init(memory: BehaviorRelay<Memory>, memoryStore: MemoryStoreType, navigationController: UINavigationController) {
        self.memory = memory
        self.memoryStore = memoryStore
        self.navigationController = navigationController
    }
    
    func start() {
        assert(false, "should be overriden, don't call this function in child class")
    }
}

extension MemoryEditCoordinator {
    
    func bindToViewModel(_ viewModel: MemoryEditViewModelType) {
        processPhotoDetail(viewModel)
        processPhotoInsert(viewModel)
        processPhotoShare(viewModel)
        processTagAdd(viewModel)
        processGraffitiInsert(viewModel)
        processStackCleaning(viewModel)
        processVoiceInsert(viewModel)
    }
    
    // MARK: Convenience methods
    private func processPhotoDetail(_ viewModel: MemoryEditViewModelType) {
        viewModel.outputs.photoDetailRequestObservable
            .subscribe(onNext: { [weak self] (image) in
                if let self = self {
                    let localViewModel = LocalImageDetailViewModel(image: image)
                    let viewController = ImageDetailViewController(localViewModel)
                    
                    localViewModel
                        .outputs
                        .closeRequestObservable
                        .subscribe(onNext: {
                            viewController.dismiss(animated: true)
                        })
                        .disposed(by: self.disposeBag)
                    
                    localViewModel
                        .outputs
                        .moreRequestObservable
                        .subscribe(onNext: {
                            Alertift.actionSheet()
                                .popover(anchorView: viewController.moreButton)
                                .action(.default("Share")) {
                                    localViewModel.outputs.image
                                    .subscribe(onNext: { (data) in
                                        DispatchQueue.global(qos: .background).async {
                                            if let image = UIImage(data: data) {
                                                let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                                                DispatchQueue.main.async {
                                                    viewController.present(activityController, animated: true)
                                                }
                                            }
                                        }
                                    })
                                    .disposed(by: self.disposeBag)
                                }
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
    
    private func processPhotoInsert(_ viewModel: MemoryEditViewModelType) {
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
    
    private func processPhotoShare(_ viewModel: MemoryEditViewModelType) {
        viewModel
            .outputs
            .photoShareRequestObservable
            .subscribe(onNext: { [weak self] (data) in
                DispatchQueue.global(qos: .background).async {
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
    
    private func processTagAdd(_ viewModel: MemoryEditViewModelType) {
        viewModel
            .outputs
            .tagAddRequestObservable
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
    
    private func processGraffitiInsert(_ viewModel: MemoryEditViewModelType) {
        viewModel.outputs.graffitiInsertRequestObservable
            .subscribe(onNext: { [weak self] in
                if let self = self,
                    let vc = self.viewController {
                    
                    let coord = GraffitiCreateCoordinator(vc)
                    
                    coord
                        .outputs
                        .saveObservable
                        .subscribe(onNext: { [weak self] (graffiti) in
                            
                            viewModel.inputs.graffitiInsertResponse(graffiti)
                            
                            vc.dismiss(animated: true)
                            self?.childCoordinators.removeLast()
                            
                        }).disposed(by: self.disposeBag)
                    
                    coord
                        .outputs
                        .closeObservable
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
    
    private func processStackCleaning(_ viewModel: MemoryEditViewModelType) {
        viewModel
            .outputs
            .shouldClearStack
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                if !self.childCoordinators.isEmpty {
                    self.childCoordinators.removeAll()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func processVoiceInsert(_ viewModel: MemoryEditViewModelType) {
        viewModel
            .outputs
            .voiceInsertRequestObservable
            .subscribe(onNext: { [weak self] manager in
                guard let self = self else { return }
                let coordinator = VoiceRecordCoordinator(presentingController: self.viewController, manager: manager)
                self.childCoordinators.append(coordinator)
                coordinator.start()
            })
            .disposed(by: disposeBag)
    }
}

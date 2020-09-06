//
//  ImagesProposalCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/20/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import Alertift


class ImageProposalCoordinator: ParentCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    var metaObservable: Observable<ImageMeta> { metaObserver.asObservable() }
    var cancelObservable: Observable<Void> { cancelObserver.asObservable() }
    
    let imagePicker = ImagePicker()
    
    let presentingController: UIViewController
    
    // MARK: Private
    private let disposeBag = DisposeBag()
    
    private let metaObserver = PublishSubject<ImageMeta>()
    private let cancelObserver = PublishSubject<Void>()
    
    // MARK: Init
    init(presentingController: UIViewController) {
        self.presentingController = presentingController
    }
    
    func start() {
        Alertift.actionSheet()
            .action(.default("Pick on Unsplash")) { [weak self] in
                self?.presentUnsplashCollection()
            }
            .action(.default("Photo Library")) { [weak self] in
                self?.presentGallery()
            }
            .action(.default("Take Photo")) { [weak self] in
                self?.presentCamera()
            }
            .action(.cancel("Cancel"))
            .show(on: presentingController)
    }
    
    private func presentUnsplashCollection() {
        let coordinator = UnsplashImageCollectionCoordinator(presentingController: self.presentingController)
        
        self.childCoordinators.append(coordinator)
        
        coordinator.metaObservable
            .bind(to: self.metaObserver)
            .disposed(by: self.disposeBag)
        
        coordinator.cancelObservable
            .bind(to: self.cancelObserver)
            .disposed(by: self.disposeBag)
        
        coordinator.start()
    }
    
    private func presentGallery() {
        imagePicker.prepareGallery({ [weak self] (controller) in
            self?.presentingController.present(controller, animated: true)
        }, completion: { [weak self] (meta) in
            self?.presentingController.dismiss(animated: true)
            self?.metaObserver.onNext(meta)
            self?.cancelObserver.onNext(())
        })
    }
    
    private func presentCamera() {
        imagePicker.prepareCamera({ [weak self] (controller) in
            self?.presentingController.present(controller, animated: true)
        }, completion: { [weak self] (meta) in
            self?.presentingController.dismiss(animated: true)
            self?.metaObserver.onNext(meta)
            self?.cancelObserver.onNext(())
        })
    }
    
}

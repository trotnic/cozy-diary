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
    
    var metaObservable: Observable<ImageMeta> {
        metaObserver.asObservable()
    }
    
    var cancelObservable: Observable<Void> {
        cancelObserver.asObservable()
    }
    
    let imagePicker = ImagePicker()
    var viewController: ImageProposalSheetController!
    
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
            .action(.default("Pick on Unsplash")) { [weak self] (action, tag) in
                guard let self = self else { return }
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
            .action(.default("Photo Library")) { [weak self] (action, tag) in
                self?.imagePicker.prepareGallery({ (controller) in
                    self?.presentingController.present(controller, animated: true)
                }, completion: { (meta) in
                    self?.presentingController.dismiss(animated: true)
                    self?.metaObserver.onNext(meta)
                    self?.cancelObserver.onNext(())
                })
                
            }
            .action(.default("Take Photo")) { [weak self] (action, tag) in
                self?.imagePicker.prepareCamera({ (controller) in
                    self?.presentingController.present(controller, animated: true)
                }, completion: { (meta) in
                    self?.presentingController.dismiss(animated: true)
                    self?.metaObserver.onNext(meta)
                    self?.cancelObserver.onNext(())
                })
            }
            .action(.cancel("Cancel"))
            .show(on: presentingController)
    }
    
}

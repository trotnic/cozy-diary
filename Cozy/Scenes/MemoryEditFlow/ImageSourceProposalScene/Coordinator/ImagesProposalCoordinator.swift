//
//  ImagesProposalCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/20/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift

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
    
    let navigationController: UINavigationController
    let presentationController: UIViewController
    
    // MARK: Private
    private let disposeBag = DisposeBag()
    
    private let metaObserver = PublishSubject<ImageMeta>()
    private let cancelObserver = PublishSubject<Void>()
    
    // MARK: Init
    init(presentationController: UIViewController, navigationController: UINavigationController) {
        self.presentationController = presentationController
        self.navigationController = navigationController
    }
    
    func start() {
        viewController = .init()
        
        let viewModel = ImageProposalViewModel(title: "Choose image source", message: "")
        viewController.viewModel = viewModel
        
        viewModel.outputs.unsplashObservable.subscribe(onNext: { _ in
                
            let coordinator = UnsplashImageCollectionCoordinator(presentingController: self.presentationController)
            
                self.childCoordinators.append(coordinator)
                
                coordinator.metaObservable
                    .bind(to: self.metaObserver)
                    .disposed(by: self.disposeBag)
                
                coordinator.cancelObservable
                    .bind(to: self.cancelObserver)
                    .disposed(by: self.disposeBag)
                
                coordinator.start()
                
                
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.galleryObservable.subscribe(onNext: { [weak self] (_) in
                self?.imagePicker.prepareGallery({ (controller) in
                    self?.presentationController.present(controller, animated: true)
                }, completion: { (meta) in
                    self?.presentationController.dismiss(animated: true)
                    self?.metaObserver.onNext(meta)
                    self?.cancelObserver.onNext(())
                })
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.cameraObservable.subscribe(onNext: { [weak self] (_) in
                self?.imagePicker.prepareCamera({ (controller) in
                    self?.presentationController.present(controller, animated: true)
                }, completion: { (meta) in
                    self?.presentationController.dismiss(animated: true)
                    self?.metaObserver.onNext(meta)
                    self?.cancelObserver.onNext(())
                })
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.cancelObservable
            .bind(to: cancelObserver)
            .disposed(by: disposeBag)
        
        presentationController.present(viewController, animated: true)
    }
    
}

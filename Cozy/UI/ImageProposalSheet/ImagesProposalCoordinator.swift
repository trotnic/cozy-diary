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
    
    var metaObservable: Observable<ImageMeta>
    
    let imagePicker = ImagePicker()
    var viewController: ImageProposalSheetController!
    
    let navigationController: UINavigationController
    let presentationController: UIViewController
    
    // MARK: Private
    private let disposeBag = DisposeBag()
    private let metaPublisher = PublishSubject<ImageMeta>()
    
    // MARK: Init
    init(presentationController: UIViewController, navigationController: UINavigationController) {
        self.presentationController = presentationController
        self.navigationController = navigationController
        
        metaObservable = metaPublisher.asObservable()
    }
    
    func start() {
        viewController = .init()
        
        let viewModel = ImageProposalViewModel(title: "Choose image source", message: "")
        viewController.viewModel = viewModel
        
        viewModel.outputs.unsplashObservable.subscribe(onNext: { [weak self] in
                if let self = self {
                    let coordinator = UnsplashImageCollectionCoordinator()
                    coordinator.start()
                    
                    self.childCoordinators.append(coordinator)
                    
                    coordinator.viewController.hidesBottomBarWhenPushed = true
                    coordinator.viewController.stubSwipeToLeft()
                    
                    
                    self.navigationController.pushViewController(coordinator.viewController, animated: true)
                    
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.galleryObservable.subscribe(onNext: { [weak self] (_) in
                self?.imagePicker.prepareGallery({ (controller) in
                    self?.presentationController.present(controller, animated: true)
                }, completion: { (meta) in
                    self?.presentationController.dismiss(animated: true)
                    self?.metaPublisher.onNext(meta)
                })
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.cameraObservable.subscribe(onNext: { [weak self] (_) in
                self?.imagePicker.prepareCamera({ (controller) in
                    self?.presentationController.present(controller, animated: true)
                }, completion: { (meta) in
                    self?.presentationController.dismiss(animated: true)
                    self?.metaPublisher.onNext(meta)
                })
            })
            .disposed(by: disposeBag)
        
        presentationController.present(viewController, animated: true)
    }
    
}

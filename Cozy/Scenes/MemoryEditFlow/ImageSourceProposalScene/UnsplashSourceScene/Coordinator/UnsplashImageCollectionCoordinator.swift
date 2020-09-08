//
//  UnsplashImageCollectionCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/26/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import Kingfisher
import Alertift


class UnsplashImageCollectionCoordinator: ParentCoordinator {
    
    var metaObservable: Observable<ImageMeta> {
        metaObserver.asObservable()
    }
    
    var childCoordinators: [Coordinator] = []
    
    var cancelObservable: Observable<Void> {
        cancelObserver.asObservable()
    }
    
    var viewController: UnsplashImageCollectionController!
    let presentingController: UIViewController
    var viewModel: UnsplashImageCollectionViewModel!
    
    private let disposeBag = DisposeBag()
    
    private let cancelObserver = PublishSubject<Void>()
    private let metaObserver = PublishSubject<ImageMeta>()
    
    init(presentingController: UIViewController) {
        self.presentingController = presentingController
    }
    
    func start() {
        
        viewModel = UnsplashImageCollectionViewModel(service: UnsplashService())
        
        viewModel
            .outputs
            .detailImageRequest
            .asObservable()
            .subscribe(onNext: { [weak self] (photo) in
                self?.gotodetail(meta: photo)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .outputs
            .cancelObservable
            .bind(to: cancelObserver)
            .disposed(by: disposeBag)
        
        viewController = UnsplashImageCollectionController(viewModel: viewModel)
        
        let wrapController = NMNavigationController(rootViewController: viewController)
        wrapController.modalPresentationStyle = .fullScreen
        
        presentingController.present(wrapController, animated: true)
    }
    
    private func gotodetail(meta: UnsplashPhoto) {
        let viewModel = UnsplashImageDetailViewModel(imageMeta: meta, imageDownloader: .default)
        let controller = ImageDetailViewController(viewModel)
        controller.modalPresentationStyle = .fullScreen
        
        viewModel
            .outputs
            .closeRequestObservable
            .subscribe(onNext: {
                controller.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .outputs
            .moreRequestObservable
            .subscribe(onNext: {
                
                Alertift.actionSheet()
                    .popover(anchorView: controller.moreButton)
                    .action(.default("Add")) {
                        viewModel.outputs.image
                        .subscribe(onNext: { [weak self] (data) in
                            if let self = self {
                                let imageMeta = ImageMeta(imageUrl: URL(string: meta.urls.regular), originalImage: data)
                                self.metaObserver.onNext(imageMeta)
                                self.cancelObserver.onNext(())
                            }
                        })
                        .disposed(by: self.disposeBag)
                    }
                    .action(.default("Share")) {
                        viewModel.outputs.image
                        .subscribe(onNext: { (data) in
                            DispatchQueue.global(qos: .userInitiated).async {
                                if let image = UIImage(data: data) {
                                    let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                                    DispatchQueue.main.async {
                                        controller.present(activityController, animated: true)
                                    }
                                }
                            }
                        })
                        .disposed(by: self.disposeBag)
                    }
                    .action(.cancel("Cancel"))
                .show(on: controller)
            })
            .disposed(by: disposeBag)
        
        viewController.present(controller, animated: true)
    }
    
}

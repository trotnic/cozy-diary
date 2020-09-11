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
    
    var childCoordinators: [Coordinator] = []
    
    var metaObservable: Observable<ImageMeta> { metaObserver.asObservable() }
    var cancelObservable: Observable<Void> { cancelObserver.asObservable() }
    
    let presentingController: UIViewController
    
    var viewController: UnsplashImageCollectionController!
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
            .bind(onNext: { [weak self] (photo) in self?.gotodetail(meta: photo) })
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
        
        let provider = RemoteImageDataProvider(url: URL(string: meta.urls.regular)!, downloader: .default)
        let viewModel = ImageDetailViewModel(provider: provider)
         
        let controller = ImageDetailViewController(viewModel)
        controller.modalPresentationStyle = .fullScreen
        
        viewModel
            .outputs
            .moreRequestObservable
            .bind(onNext: {
                
                Alertift.actionSheet()
                    .popover(anchorView: controller.moreButton)
                    .action(.default("Add")) {
                        viewModel.outputs.image
                        .subscribe(onNext: { [weak self] (data) in
                            let imageMeta = ImageMeta(imageUrl: URL(string: meta.urls.regular), originalImage: data)
                            self?.metaObserver.onNext(imageMeta)
                            self?.cancelObserver.onNext(())
                        })
                        .disposed(by: self.disposeBag)
                    }
                    .action(.default("Share")) {
                        viewModel.outputs.image
                        .subscribe(onNext: { (data) in
                            let activityController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                            DispatchQueue.main.async { controller.present(activityController, animated: true) }
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

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


class UnsplashImageCollectionCoordinator: ParentCoordinator {
    
    var metaObservable: Observable<ImageMeta> {
        metaObserver.asObservable()
    }
    
    var childCoordinators: [Coordinator] = []
    
    var cancelObservable: Observable<Void> {
        cancelObserver.asObservable()
    }
    
    var viewController: UnsplashImageCollectionController!
    var viewModel: UnsplashImageCollectionViewModel!
    
    private let disposeBag = DisposeBag()
    
    private let cancelObserver = PublishSubject<Void>()
    private let metaObserver = PublishSubject<ImageMeta>()
    
    func start() {
        
        viewModel = UnsplashImageCollectionViewModel(service: UnsplashService())
        
        viewModel.outputs.detailImageRequest
            .asObservable()
            .subscribe(onNext: { [weak self] (photo) in
                self?.gotodetail(meta: photo)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.cancelObservable
            .bind(to: cancelObserver)
            .disposed(by: disposeBag)
        
        viewController = UnsplashImageCollectionController(viewModel: viewModel)        
    }
    
    private func gotodetail(meta: UnsplashPhoto) {
        let viewModel = UnsplashImageDetailViewModel(imageMeta: meta)
        let controller = ImageDetailViewController(viewModel)
        controller.modalPresentationStyle = .fullScreen
        
        viewModel.outputs.closeRequestObservable
            .subscribe(onNext: {
                controller.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.moreRequestObservable
            .subscribe(onNext: {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let addAction = UIAlertAction(
                    title: "Add",
                    style: .default) { (_) in
                        viewModel.outputs.image
                            .subscribe(onNext: { [weak self] (data) in
                                let imageMeta = ImageMeta(imageUrl: URL(string: meta.urls.regular), originalImage: data)
                                self?.metaObserver.onNext(imageMeta)
                            })
                            .disposed(by: self.disposeBag)
                }
                alertController.addAction(addAction)
                
                let shareAction = UIAlertAction(
                    title: "Share",
                    style: .default) { (_) in
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
                alertController.addAction(shareAction)
                
                let cancelAction = UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: nil)
                alertController.addAction(cancelAction)
                
                controller.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewController.present(controller, animated: true)
    }
    
}

//
//  ImagesProposalCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/20/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift

class ImageProposalCoordinator: Coordinator {
    
    var metaObservable: Observable<ImageMeta>
    
    let imagePicker = ImagePicker()
    var viewController: ImageProposalSheetController!
    let presentationController: UIViewController
    private let disposeBag = DisposeBag()
    private let metaPublisher = PublishSubject<ImageMeta>()
    
    init(presentationController: UIViewController) {
        self.presentationController = presentationController
        metaObservable = metaPublisher.asObservable()
    }
    
    func start() {
        viewController = .init()
        let viewModel = ImageProposalViewModel(title: "Choose image source", message: "")
        viewController.viewModel = viewModel
        
        viewModel.outputs.galleryObservable.subscribe(onNext: { [weak self] (_) in
            self?.imagePicker.prepareGallery({ (controller) in
                self?.presentationController.present(controller, animated: true)
            }, completion: { (meta) in
                self?.presentationController.dismiss(animated: true)
                self?.metaPublisher.onNext(meta)
            })
        }).disposed(by: disposeBag)
        
        viewModel.outputs.cameraObservable.subscribe(onNext: { [weak self] (_) in
            self?.imagePicker.prepareCamera({ (controller) in
                self?.presentationController.present(controller, animated: true)
            }, completion: { (meta) in
                self?.presentationController.dismiss(animated: true)
                self?.metaPublisher.onNext(meta)
            })
        }).disposed(by: disposeBag)
        
        presentationController.present(viewController, animated: true)
    }
    
}

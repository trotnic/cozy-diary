//
//  ImageDetailCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/19/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ImageDetailCoordinator: Coordinator {
    
    private let controller: UIViewController
    private let image: Data
    private let disposeBag = DisposeBag()
    
    init(_ presentationController: UIViewController, image: Data) {
        controller = presentationController
        self.image = image
    }
    
    func start() {
        let viewModel = ImageDetailViewModel(image: image)
        let vc = ImageDetailViewController(viewModel)
        
        viewModel.outputs.closeRequestObservable
            .subscribe(onNext: { [weak self] in
                
            self?.controller.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.shareRequestObservable
            .subscribe(onNext: { [weak self] in
                
                DispatchQueue.global(qos: .userInitiated).async {
                    if let data = self?.image,
                        let image = UIImage(data: data){
                        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                        DispatchQueue.main.async {
                            vc.present(activityController, animated: true)
                        }                        
                    }
                }
        }).disposed(by: disposeBag)
        
        vc.modalPresentationStyle = .overFullScreen
        controller.present(vc, animated: true)
    }
    
}

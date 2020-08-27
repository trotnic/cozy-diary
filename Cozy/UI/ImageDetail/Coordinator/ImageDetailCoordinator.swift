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
    
    var controller: ImageDetailViewController!
    private let image: Data
    private let disposeBag = DisposeBag()
    
    init(image: Data) {
        self.image = image
    }
    
    func start() {
        let viewModel = ImageDetailViewModel(image: image)
        controller = ImageDetailViewController(viewModel)
        controller.modalPresentationStyle = .fullScreen
        
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
                            self?.controller.present(activityController, animated: true)
                        }                        
                    }
                }
        }).disposed(by: disposeBag)
        
        
    }
    
}

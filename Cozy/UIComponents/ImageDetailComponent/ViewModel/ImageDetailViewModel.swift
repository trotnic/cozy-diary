//
//  ImageDetailViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/11/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class ImageDetailViewModel: ImageDetailViewModelType, ImageDetailViewModelOutput, ImageDetailViewModelInput {
    
    // MARK: Outputs & Inputs
    var outputs: ImageDetailViewModelOutput { self }
    var inputs: ImageDetailViewModelInput { self }
    
    // MARK: Outputs
    var image: Observable<Data> { imageObserver.asObservable() }

    var moreRequestObservable: Observable<Void> { moreButtonTap.asObservable() }
    
    // MARK: Inputs
    let closeButtonTap = PublishRelay<Void>()
    let moreButtonTap = PublishRelay<Void>()
    
    // MARK: Private
    private let disposeBag = DisposeBag()
    private let imageObserver = BehaviorRelay<Data>(value: Data())
    private let provider: ImageDataProviderType
    
    // MARK: Init
    init(provider: ImageDataProviderType) {
        self.provider = provider
        
        provider.image
            .bind(to: imageObserver)
            .disposed(by: disposeBag)
    }
}

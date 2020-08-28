//
//  ImageDetailViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/19/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift


class LocalImageDetailViewModel: ImageDetailViewModelType, ImageDetailViewModelOutput, ImageDetailViewModelInput {
    
    var outputs: ImageDetailViewModelOutput { return self }
    var inputs: ImageDetailViewModelInput { return self }
    
    // MARK: Outputs
    var image: Observable<Data>
    
    var closeRequestObservable: Observable<Void> {
        closeObserver.asObservable()
    }
    
    var moreRequestObservable: Observable<Void> {
        shareObserver.asObservable()
    }
    
    // MARK: Inputs
    let closeObserver = PublishRelay<Void>()
    let shareObserver = PublishRelay<Void>()
    
    // MARK: Private
    
    
    init(image: Data) {
        self.image = .just(image)
    }
    
}

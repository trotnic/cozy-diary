//
//  UnsplashImageDetailViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/26/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift


class UnsplashImageDetailViewModel: ImageDetailViewModelType, ImageDetailViewModelOutput, ImageDetailViewModelInput {
    
    var outputs: ImageDetailViewModelOutput { return self }
    var inputs: ImageDetailViewModelInput { return self }
    
    // MARK: Outputs
    var image: Observable<Data> {
        imageObserver.asObservable()
    }
    
    var closeRequestObservable: Observable<Void> {
        closeObserver.asObservable()
    }
    
    var shareRequestObservable: Observable<Void> {
        shareObserver.asObservable()
    }
    
    // MARK: Inputs
    let closeObserver = PublishRelay<Void>()
    let shareObserver = PublishRelay<Void>()
    
    // MARK: Private
    private let imageMeta: UnsplashPhoto
    private let disposeBag = DisposeBag()
    
    private let imageObserver = PublishRelay<Data>()
    
    // MARK: Init
    init(imageMeta: UnsplashPhoto) {
        self.imageMeta = imageMeta
        
    }
}

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

protocol ImageDetailViewModelOutput {
    var image: Observable<Data> { get }
    
    var closeRequestObservable: Observable<Void> { get }
    var shareRequestObservable: Observable<Void> { get }
}

protocol ImageDetailViewModelInput {
    var closeObserver: PublishRelay<Void> { get }
    var shareObserver: PublishRelay<Void> { get }
}

protocol ImageDetailViewModelType {
    var outputs: ImageDetailViewModelOutput { get }
    var inputs: ImageDetailViewModelInput { get }
}

class ImageDetailViewModel: ImageDetailViewModelType, ImageDetailViewModelOutput, ImageDetailViewModelInput {
    
    var outputs: ImageDetailViewModelOutput { return self }
    var inputs: ImageDetailViewModelInput { return self }
    
    // MARK: Outputs
    var image: Observable<Data>
    
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
    
    
    init(image: Data) {
        self.image = .just(image)
    }
    
}

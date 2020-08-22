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
    var closeRequest: () -> () { get }
    var shareRequest: () -> () { get }
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
    
    var closeRequestObservable: Observable<Void>
    var shareRequestObservable: Observable<Void>
    
    // MARK: Inputs
    lazy var closeRequest = { { self.closePublisher.onNext(()) } }()
    lazy var shareRequest = { { self.sharePublisher.onNext(()) } }()
    
    // MARK: Private
    var closePublisher = PublishSubject<Void>()
    var sharePublisher = PublishSubject<Void>()
    
    init(image: Data) {
        self.image = .just(image)
        
        closeRequestObservable = closePublisher.asObservable()
        shareRequestObservable = sharePublisher.asObservable()
    }
    
}

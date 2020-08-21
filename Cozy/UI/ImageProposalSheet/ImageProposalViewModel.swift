//
//  ImageProposalViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/20/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift


protocol ImageProposalViewModelOutput {
    var title: Observable<String> { get }
    var message: Observable<String> { get }
    
    var unsplashObservable: Observable<Void> { get }
    var galleryObservable: Observable<Void> { get }
    var cameraObservable: Observable<Void> { get }
}

protocol ImageProposalViewModelInput {
    var unsplashAction: () -> () { get }
    var galleryAction: () -> () { get }
    var cameraAction: () -> () { get }
}

protocol ImageProposalViewModelType {
    var outputs: ImageProposalViewModelOutput { get }
    var inputs: ImageProposalViewModelInput { get }
    
}

class ImageProposalViewModel: ImageProposalViewModelType, ImageProposalViewModelOutput, ImageProposalViewModelInput {
    
    // MARK: Inputs & Outputs
    var outputs: ImageProposalViewModelOutput { return self }
    var inputs: ImageProposalViewModelInput { return self }
    
    // MARK: Outputs
    let title: Observable<String>
    let message: Observable<String>
    
    let unsplashObservable: Observable<Void>
    let galleryObservable: Observable<Void>
    let cameraObservable: Observable<Void>
    
    // MARK: Inputs
    lazy var unsplashAction = { { self.unsplashPublisher.onNext(()) } }()
    lazy var galleryAction = { { self.galleryPublisher.onNext(()) } }()
    lazy var cameraAction = { { self.cameraPublisher.onNext(()) } }()
    
    // MARK: Private
    private let unsplashPublisher = PublishSubject<Void>()
    private let galleryPublisher = PublishSubject<Void>()
    private let cameraPublisher = PublishSubject<Void>()
    
    // MARK: Init
    init(title: String, message: String) {
        
        self.title = Observable.just(title)
        self.message = Observable.just(message)
        
        unsplashObservable = unsplashPublisher.asObservable()
        galleryObservable = galleryPublisher.asObservable()
        cameraObservable = cameraPublisher.asObservable()
    }
    
}

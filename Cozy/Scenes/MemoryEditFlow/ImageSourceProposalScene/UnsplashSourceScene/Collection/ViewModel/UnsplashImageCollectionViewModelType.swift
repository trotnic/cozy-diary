//
//  UnsplashImageCollectionViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import RxSwift
import RxCocoa


protocol UnsplashImageCollectionViewModelOutput {
    var items: Driver<[UnsplashCollectionSection]> { get }
    
    var detailImageRequest: Signal<UnsplashPhoto> { get }
    
    var cancelObservable: Observable<Void> { get }
}

protocol UnsplashImageCollectionViewModelInput {
    var didScrollToEnd: PublishRelay<Void> { get }
    var willDisappear: PublishRelay<Void> { get }
    
    var searchObserver: PublishRelay<String> { get }
    var searchCancelObserver: PublishRelay<Void> { get }
}

protocol UnsplashImageCollectionViewModelType {
    var outputs: UnsplashImageCollectionViewModelOutput { get }
    var inputs: UnsplashImageCollectionViewModelInput { get }
}

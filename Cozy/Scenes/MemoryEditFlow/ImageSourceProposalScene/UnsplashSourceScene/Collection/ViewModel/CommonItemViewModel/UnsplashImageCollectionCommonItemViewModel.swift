//
//  UnsplashImageCollectionCommonItemViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class UnsplashImageCollectionCommonItemViewModel: UnsplashImageCollectionCommonItemViewModelType, UnsplashImageCollectionCommonItemViewModelOutput, UnsplashImageCollectionCommonItemViewModelInput {
    
    var outputs: UnsplashImageCollectionCommonItemViewModelOutput { return self }
    var inputs: UnsplashImageCollectionCommonItemViewModelInput { return self }
    
    // MARK: Outputs
    var image: Driver<URL?> { imageObserver.asDriver() }
    var detailRequest: Signal<Void> { tapRequest.asSignal() }
    
    // MARK: Inputs
    let tapRequest = PublishRelay<Void>()
    
    // MARK: Private
    private let item: UnsplashPhoto
    private let disposeBag = DisposeBag()
    
    private let imageObserver = BehaviorRelay<URL?>(value: nil)
    
    // MARK: Init
    init(item: UnsplashPhoto) {
        self.item = item
        imageObserver.accept(URL(string: self.item.urls.small))
    }
}

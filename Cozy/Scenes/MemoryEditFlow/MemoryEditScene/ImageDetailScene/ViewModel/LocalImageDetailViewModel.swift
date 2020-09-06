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
    var image: Observable<Data> { imageObserver.asObservable() }
    var closeRequestObservable: Observable<Void> { closeButtonTap.asObservable() }
    var moreRequestObservable: Observable<Void> { moreButtonTap.asObservable() }
    
    // MARK: Inputs
    let closeButtonTap = PublishRelay<Void>()
    let moreButtonTap = PublishRelay<Void>()
    
    // MARK: Private
    private let imageObserver: BehaviorRelay<Data>
    
    init(image: Data) {
        imageObserver = .init(value: image)
    }
    
}

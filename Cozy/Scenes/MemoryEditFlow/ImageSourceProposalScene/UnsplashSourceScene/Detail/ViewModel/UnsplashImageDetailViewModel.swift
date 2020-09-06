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
import Kingfisher


class UnsplashImageDetailViewModel: ImageDetailViewModelType, ImageDetailViewModelOutput, ImageDetailViewModelInput {
    
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
    private let imageMeta: UnsplashPhoto
    private let disposeBag = DisposeBag()
    
    private let imageObserver = BehaviorRelay<Data>(value: Data())
    private let imageDownloader: ImageDownloader
    
    // MARK: Init
    init(imageMeta: UnsplashPhoto, imageDownloader: ImageDownloader) {
        self.imageMeta = imageMeta
        self.imageDownloader = imageDownloader
        
        self.imageDownloader
            .downloadImage(with: URL(string: self.imageMeta.urls.regular)!) { [weak self] result in
                switch result {
                case let .success(value):
                    self?.imageObserver.accept(value.originalData)
                case let .failure(error):
                    print(error)
                }
            }
        
    }
}

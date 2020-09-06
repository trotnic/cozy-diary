//
//  PhotoChunkViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/4/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class PhotoChunkViewModel: PhotoChunkViewModelType, PhotoChunkViewModelOutput, PhotoChunkViewModelInput {
    var outputs: PhotoChunkViewModelOutput { return self }
    var inputs: PhotoChunkViewModelInput { return self }
    
    // MARK: Outputs
    var photo: BehaviorRelay<Data>
    
    var detailPhotoRequestObservable: Observable<Void> { tap.asObservable() }
    
    var sharePhotoRequest: Observable<Void> { shareButtonTap.asObservable() }
    var copyPhotoRequest: Observable<Void> { copyButtonTap.asObservable() }
    var removePhotoRequest: Observable<Void> { removeButtonTap.asObservable() }
    
    // MARK: Inputs
    
    let tap = PublishRelay<Void>()
    
    let shareButtonTap = PublishRelay<Void>()
    let copyButtonTap = PublishRelay<Void>()
    let removeButtonTap = PublishRelay<Void>()
    
    // MARK: Private
    private let chunk: PhotoChunk
    private let disposeBag = DisposeBag()
    
    private let tapRequestPublisher = PublishSubject<Void>()
    
    // MARK: Init
    init(_ chunk: PhotoChunk) {
        self.chunk = chunk
        photo = .init(value: chunk.photo)
    }
}


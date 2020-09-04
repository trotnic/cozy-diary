//
//  PhotoChunkViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/4/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol PhotoChunkViewModelOutput {
    var photo: BehaviorRelay<Data> { get }
    
    var detailPhotoRequestObservable: Observable<Void> { get }
    
    var sharePhotoRequest: Observable<Void> { get }
    var copyPhotoRequest: Observable<Void> { get }
    var removePhotoRequest: Observable<Void> { get }
}

protocol PhotoChunkViewModelInput {
    var tapRequest: () -> () { get }
    var longPressRequest: () -> () { get }
    
    var shareButtonTap: PublishRelay<Void> { get }
    var copyButtonTap: PublishRelay<Void> { get }
    var removeButtonTap: PublishRelay<Void> { get }
}

protocol PhotoChunkViewModelType {
    var outputs: PhotoChunkViewModelOutput { get }
    var inputs: PhotoChunkViewModelInput { get }
}

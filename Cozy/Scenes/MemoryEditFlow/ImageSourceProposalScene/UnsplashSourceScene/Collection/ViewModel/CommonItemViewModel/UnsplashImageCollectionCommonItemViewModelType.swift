//
//  CommonItemViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxCocoa


protocol UnsplashImageCollectionCommonItemViewModelOutput {
    var image: Driver<URL?> { get }
    var detailRequest: Signal<Void> { get }
}

protocol UnsplashImageCollectionCommonItemViewModelInput {
    var tapRequest: PublishRelay<Void> { get }
}

protocol UnsplashImageCollectionCommonItemViewModelType {
    var outputs: UnsplashImageCollectionCommonItemViewModelOutput { get }
    var inputs: UnsplashImageCollectionCommonItemViewModelInput { get }
}

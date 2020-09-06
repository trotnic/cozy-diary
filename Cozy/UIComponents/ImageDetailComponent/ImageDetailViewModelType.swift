//
//  ImageDetailViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol ImageDetailViewModelOutput {
    var image: Observable<Data> { get }
    
    var closeRequestObservable: Observable<Void> { get }
    var moreRequestObservable: Observable<Void> { get }
}

protocol ImageDetailViewModelInput {
    var closeButtonTap: PublishRelay<Void> { get }
    var moreButtonTap: PublishRelay<Void> { get }
}

protocol ImageDetailViewModelType {
    var outputs: ImageDetailViewModelOutput { get }
    var inputs: ImageDetailViewModelInput { get }
}

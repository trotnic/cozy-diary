//
//  LocalImageDataProvider.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/11/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift


class LocalImageDataProvider: ImageDataProviderType {
    
    var image: Observable<Data> { imageObserver.asObservable() }
    
    private let imageObserver = BehaviorSubject<Data>(value: Data())
    
    init(data: Data) {
        imageObserver.onNext(data)
    }
}

//
//  MemoryCollectionCommonItemViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol MemoryCollectionCommonItemViewModelOutput {
    var date: Observable<String> { get }
    var text: Observable<String> { get }
    var image: Observable<Data?> { get }
    
    var tapRequestObservable: Observable<Void> { get }
}

protocol MemoryCollectionCommonItemViewModelInput {
    var tap: PublishRelay<Void> { get }
}

protocol MemoryCollectionCommonItemViewModelType {
    var outputs: MemoryCollectionCommonItemViewModelOutput { get }
    var inputs: MemoryCollectionCommonItemViewModelInput { get }
}

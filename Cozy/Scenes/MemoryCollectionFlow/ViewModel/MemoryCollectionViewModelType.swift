//
//  MemoryCollectionViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol MemoryCollectionViewModelOutput {
    var items: Driver<[MemoryCollectionViewSection]> { get }
    
    var detailRequestObservable: Observable<BehaviorRelay<Memory>> { get }
    var searchRequestObservable: Observable<Void> { get }
    var addRequestObservable: Observable<Void> { get }
}

protocol MemoryCollectionViewModelInput {
    var searchButtonTap: PublishRelay<Void> { get }
    var addButtonTap: PublishRelay<Void> { get }
    
    var viewWillAppear: PublishRelay<Void> { get }
}

protocol MemoryCollectionViewModelType {
    var outputs: MemoryCollectionViewModelOutput { get }
    var inputs: MemoryCollectionViewModelInput { get }
}

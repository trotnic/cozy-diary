//
//  MemorySearchViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import RxCocoa
import RxSwift


protocol MemorySearchViewModelOutput {
    var items: Driver<[MemoryCollectionViewSection]> { get }
    
    var dismissCurrentController: Observable<Void> { get }
    var showFilter: Observable<FilterManagerType> { get }
    var showDetail: Observable<BehaviorRelay<Memory>> { get }
}

protocol MemorySearchViewModelInput {
    var searchButtonTap: PublishRelay<Void> { get }
    
    var searchObserver: PublishRelay<String> { get }
    var searchCancelObserver: PublishRelay<Void> { get }
    
    var filterButtonTap: PublishRelay<Void> { get }
    var closeButtonTap: PublishRelay<Void> { get }
    var didSelectItem: PublishRelay<BehaviorRelay<Memory>> { get }
}

protocol MemorySearchViewModelType {
    var outputs: MemorySearchViewModelOutput { get }
    var inputs: MemorySearchViewModelInput { get }
}

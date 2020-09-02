//
//  MemorySearchFilterViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/2/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class MemorySearchFilterViewModel: MemorySearchFilterViewModelType, MemorySearchFilterViewModelOutput, MemorySearchFilterViewModelInput {
    
    // MARK: Outputs & Inputs
    var outputs: MemorySearchFilterViewModelOutput { return self }
    var inputs: MemorySearchFilterViewModelInput { return self }
    
    // MARK: Outputs
    var items: Driver<[MemorySearchFilterCollectionSection]> {
        manager.relevantFilters().flatMapLatest { (filters) -> Observable<[MemorySearchFilterCollectionSection]> in
            var tags: [MemorySearchFilterCollectionItem] = []
            var dates: [MemorySearchFilterCollectionItem] = []
            
            filters.forEach { (filter) in
                switch filter {
                case let .date(value):
                    dates.append(.tagItem(value: "lolkek"))
                case let .tag(value):
                    tags.append(.tagItem(value: value))
                }
            }
            
            return .just([
                .init(items: dates),
                .init(items: tags)
            ])
        }
        .asDriver(onErrorJustReturn: [])
    }
    
    // MARK: Inputs
    
    // MARK: Private
    private let manager: FilterManagerType
    
    
    // MARK: Init
    init(manager: FilterManagerType) {
        self.manager = manager
    }
    
}

//
//  FilterManager.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/2/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


enum Filter: Equatable, Hashable {
    case tag(_ value: String)
    case date(_ value: Date)
}

protocol FilterManagerType: class {
    func relevantFilters() -> Observable<[Filter]>
    func insertFilter(_ filter: Filter)
    func removeFilter(_ filter: Filter)
    func clearFilters()
}

class FilterManager: FilterManagerType {
    
    var filtersBag = BehaviorRelay<Set<Filter>>(value: [])
    
    func relevantFilters() -> Observable<[Filter]> {
//        filtersBag.flatMap { filters -> Observable<[Filter]> in .just(Array(filters)) }
        
        filtersBag.flatMap { filters -> Observable<[Filter]> in
            .just([.tag("one"),.tag("one"),.tag("one"),.tag("one"),.tag("one")])            
        }
    }
    
    func insertFilter(_ filter: Filter) {
        var currentFilters = filtersBag.value
        currentFilters.insert(filter)
        filtersBag.accept(currentFilters)
    }
    
    func removeFilter(_ filter: Filter) {
        let currentFilters = filtersBag.value
        filtersBag.accept(currentFilters.filter { $0 != filter })
    }
    
    func clearFilters() {
        filtersBag.accept([])
    }
}

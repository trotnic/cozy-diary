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
    func allFilters() -> Set<Filter>
    func currentFilters() -> Set<Filter>
    func allFiltersObservable() -> Observable<Set<Filter>>
    func selectedFiltersObservable() -> Observable<Set<Filter>>
    func insertFilter(_ filter: Filter)
    func removeFilter(_ filter: Filter)
    func clearFilters()
    func refillInitialFiltersWith(_ filters: [Filter])
}

class FilterManager: FilterManagerType {
    
    private let selectedFiltersBag = BehaviorRelay<Set<Filter>>(value: [])
    private let allFiltersBag = BehaviorRelay<Set<Filter>>(value: [])
    
    func allFilters() -> Set<Filter> {
        allFiltersBag.value
    }
    
    func currentFilters() -> Set<Filter> {
        selectedFiltersBag.value
    }
    
    func refillInitialFiltersWith(_ filters: [Filter]) {
        allFiltersBag.accept(Set(filters))
    }
    
    func allFiltersObservable() -> Observable<Set<Filter>> {
        allFiltersBag.asObservable()
    }
    
    func selectedFiltersObservable() -> Observable<Set<Filter>> {
        selectedFiltersBag.asObservable()
    }
    
    func insertFilter(_ filter: Filter) {
        var currentFilters = selectedFiltersBag.value
        currentFilters.insert(filter)
        selectedFiltersBag.accept(currentFilters)
    }
    
    func removeFilter(_ filter: Filter) {
        let currentFilters = selectedFiltersBag.value
        selectedFiltersBag.accept(currentFilters.filter { $0 != filter })
    }
    
    func clearFilters() {
        selectedFiltersBag.accept([])
    }
}

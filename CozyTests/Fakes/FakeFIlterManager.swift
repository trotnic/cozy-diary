//
//  FakeFIlterManager.swift
//  CozyTests
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import RxSwift
import RxTest
import RxCocoa

@testable import Cozy

class FakeFilterManager: FilterManagerType {
    var allFiltersVar: BehaviorRelay<Set<Filter>> = .init(value: [])
    var currentFiltersVar: BehaviorRelay<Set<Filter>> = .init(value: [])
    
    func allFilters() -> Set<Filter> { allFiltersVar.value }
    
    func currentFilters() -> Set<Filter> { currentFiltersVar.value }
    
    func allFiltersObservable() -> Observable<Set<Filter>> { allFiltersVar.asObservable() }
    
    func selectedFiltersObservable() -> Observable<Set<Filter>> { currentFiltersVar.asObservable() }
    
    func insertFilter(_ filter: Filter) { currentFiltersVar.accept(currentFiltersVar.value.union([filter])) }
    
    func removeFilter(_ filter: Filter) { currentFiltersVar.accept(currentFiltersVar.value.subtracting([filter])) }
    
    func clearFilters() { currentFiltersVar.accept([]) }
    
    func refillInitialFiltersWith(_ filters: [Filter]) { allFiltersVar.accept(Set(filters)) }
    
    
}


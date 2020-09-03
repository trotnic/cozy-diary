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

enum Months: Equatable, Hashable {
    case january(value: String = "January", num: Int = 1)
    case february(value: String = "February", num: Int = 2)
    case march(value: String = "March", num: Int = 3)
    case april(value: String = "April", num: Int = 4)
    case may(value: String = "May", num: Int = 5)
    case june(value: String = "June", num: Int = 6)
    case july(value: String = "July", num: Int = 7)
    case august(value: String = "August", num: Int = 8)
    case september(value: String = "September", num: Int = 9)
    case october(value: String = "October", num: Int = 10)
    case november(value: String = "November", num: Int = 11)
    case december(value: String = "December", num: Int = 12)
}

enum Filter: Equatable, Hashable {
    case tag(_ value: String)
    case date(_ value: Months)
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
    private let allFiltersBag = BehaviorRelay<Set<Filter>>(value: defaultFilters())
    
    func allFilters() -> Set<Filter> {
        allFiltersBag.value
    }
    
    func currentFilters() -> Set<Filter> {
        selectedFiltersBag.value
    }
    
    func refillInitialFiltersWith(_ filters: [Filter]) {
        allFiltersBag.accept(Set(filters).union(FilterManager.defaultFilters()))
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

extension FilterManager {
    private static func defaultFilters() -> Set<Filter> {
        Set([
            .date(.january()),
            .date(.february()),
            .date(.march()),
            .date(.april()),
            .date(.may()),
            .date(.june()),
            .date(.july()),
            .date(.august()),
            .date(.september()),
            .date(.october()),
            .date(.november()),
            .date(.december())
        ])
    }
}

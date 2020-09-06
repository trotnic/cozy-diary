//
//  FilterManagerTests.swift
//  CozyTests
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import Cozy

class FilterManagerTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    var manager: FilterManager!
    var testScheduler: TestScheduler!
    var defaultItems: Set<Filter>!
    
    override func setUpWithError() throws {
        super.setUp()
        disposeBag = DisposeBag()
        manager = FilterManager()
        testScheduler = TestScheduler(initialClock: 0)
        defaultItems = Set([
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

    override func tearDownWithError() throws {
        disposeBag = nil
        manager = nil
        testScheduler = nil
        super.tearDown()
    }
    
    func test_filtersEmpty() {
        XCTAssertEqual(manager.currentFilters(), Set<Filter>())
    }
    
    func test_filtersFilled() {
        manager.insertFilter(.tag("Tag"))
        let sampleItems: Set<Filter> = [.tag("Tag")]
        
        XCTAssertEqual(manager.currentFilters(), sampleItems)
    }
    
    func test_allFilters() {
        let item: Filter = .tag("tag")
        let sampleFilters: [Filter] = [item]
        
        manager.refillInitialFiltersWith(sampleFilters)
        
        XCTAssertEqual(manager.allFilters(), defaultItems.union(sampleFilters))
    }
    
    func test_selectedFiltersObservable() {
        let sampleItems: Set<Filter> = [.tag("Tag")]
        manager.insertFilter(.tag("Tag"))
        
        let itemsObserver = testScheduler.createObserver(Set<Filter>.self)
        
        manager.selectedFiltersObservable()
            .bind(to: itemsObserver)
        .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemsObserver.events, [sampleItems])
    }
    
    func test_allFiltersObservable() {
        let sampleItems: [Filter] = [.tag("Tag")]
        manager.refillInitialFiltersWith(sampleItems)
        
        let itemsObserver = testScheduler.createObserver(Set<Filter>.self)
        
        manager.allFiltersObservable()
            .bind(to: itemsObserver)
        .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemsObserver.events, [defaultItems.union(sampleItems)])
    }
    
    func test_removeFilter() {
        let sampleItems: Set<Filter> = []
        manager.insertFilter(.tag("Tag"))
        manager.removeFilter(.tag("Tag"))
        
        let itemsObserver = testScheduler.createObserver(Set<Filter>.self)
        
        manager.selectedFiltersObservable()
            .bind(to: itemsObserver)
        .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemsObserver.events, [sampleItems])
    }
    
    func test_clearFilters() {
        let sampleItems: Set<Filter> = []
        manager.insertFilter(.tag("One"))
        manager.insertFilter(.tag("Two"))
        manager.insertFilter(.tag("Three"))
        manager.clearFilters()

        let itemsObserver = testScheduler.createObserver(Set<Filter>.self)

        manager.selectedFiltersObservable()
           .bind(to: itemsObserver)
        .disposed(by: disposeBag)

        XCTAssertRecordedElements(itemsObserver.events, [sampleItems])
    }
}

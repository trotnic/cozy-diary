//
//  MemorySearchViewModelTests.swift
//  CozyTests
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest

@testable import Cozy

class MemorySearchViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    var viewModel: MemorySearchViewModel!
    var testScheduler: TestScheduler!
    var mockEntity: BehaviorRelay<Memory>!
    var fakeStore: FakeMemoryStore!
    var fakeFilterManager: FakeFilterManager!
    var mockMemory: Memory!
    
    override func setUpWithError() throws {
        super.setUp()
        disposeBag = DisposeBag()
        mockEntity = .init(value: .init())
        fakeStore = FakeMemoryStore()
        fakeFilterManager = FakeFilterManager()
        viewModel = .init(memoryStore: fakeStore, filterManager: fakeFilterManager)
        testScheduler = TestScheduler(initialClock: 0)
        mockMemory = Memory(
            date: Date(),
            index: 1,
            texts: [.init(text: .init(string: "some text to search"), index: 0)],
            photos: [],
            graffities: [],
            voices: [],
            tags: ["tag"]
        )
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        viewModel = nil
        mockEntity = nil
        testScheduler = nil
        fakeFilterManager = nil
        fakeStore = nil
        mockMemory = nil
        super.tearDown()
    }

    func test_items_noFilters() {
        let itemsObserver = testScheduler.createObserver(Bool.self)
        
        viewModel
            .outputs
            .items
            .asObservable()
            .flatMap { _ -> Observable<Bool> in .just(true) }
            .bind(to: itemsObserver)
            .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemsObserver.events, [true])
    }
    
    func test_items_withFilters() {
        let itemsObserver = testScheduler.createObserver(Bool.self)
        fakeStore.beforeNowMemories.accept([.init(value: mockMemory)])
        
        fakeFilterManager.insertFilter(.tag("tagOne"))
        fakeFilterManager.insertFilter(.tag("tag two"))
        fakeFilterManager.insertFilter(.date(.april(value: "april", num: 4)))
        viewModel.searchObserver.accept("")
        
        viewModel
            .outputs
            .items
            .asObservable()
            .flatMap { _ -> Observable<Bool> in .just(true) }
            .bind(to: itemsObserver)
            .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemsObserver.events, [true])
    }

    func test_items_withSearchTerm() {
        let itemsObserver = testScheduler.createObserver(Bool.self)
        
        fakeStore.beforeNowMemories.accept([.init(value: mockMemory)])
        
        viewModel.searchObserver.accept("text")
        
        viewModel
            .outputs
            .items
            .asObservable()
            .flatMap { _ -> Observable<Bool> in .just(true) }
            .bind(to: itemsObserver)
            .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemsObserver.events, [true])
    }
    
    func test_items_withEmptySearchTerm() {
        let itemsObserver = testScheduler.createObserver(Bool.self)
        
        fakeStore.beforeNowMemories.accept([.init(value: mockMemory)])
        
        viewModel.searchObserver.accept("")
        
        viewModel
            .items
            .asObservable()
            .flatMap { _ -> Observable<Bool> in .just(true) }
            .bind(to: itemsObserver)
            .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemsObserver.events, [true])
    }
    
    func test_filterButtonTap() {
        let tapObserver = testScheduler.createObserver(Bool.self)
        
        viewModel
            .showFilter
            .flatMap { _ -> Observable<Bool> in .just(true)}
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
        
        viewModel
            .inputs
            .filterButtonTap
            .accept(())
        
        XCTAssertRecordedElements(tapObserver.events, [true])
    }

    func test_closeButtonTap() {
        let tapObserver = testScheduler.createObserver(Bool.self)
        
        viewModel
            .dismissCurrentController
            .flatMap { _ -> Observable<Bool> in .just(true)}
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
        
        viewModel
            .inputs
            .closeButtonTap
            .accept(())
        
        XCTAssertRecordedElements(tapObserver.events, [true])
    }
    
    func test_didSelectItemTap() {
        let tapObserver = testScheduler.createObserver(Bool.self)
        
        viewModel
            .showDetail
            .flatMap { _ -> Observable<Bool> in .just(true)}
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
        
        viewModel
            .inputs
            .didSelectItem
            .accept(.init(value: .init()))
        
        XCTAssertRecordedElements(tapObserver.events, [true])
    }
}

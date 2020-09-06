//
//  MemoryCollectionViewModelTests.swift
//  CozyTests
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxCocoa

@testable import Cozy

class MemoryCollectionViewModelTests: XCTestCase {

    var disposeBag: DisposeBag!
    var viewModel: MemoryCollectionViewModel!
    var testScheduler: TestScheduler!
    var mockEntity: Memory!
    var fakeStore: FakeMemoryStore!
    
    override func setUpWithError() throws {
        super.setUp()
        disposeBag = DisposeBag()
        mockEntity = .init()
        testScheduler = .init(initialClock: 1)
        fakeStore = FakeMemoryStore()
        viewModel = MemoryCollectionViewModel(memoryStore: fakeStore)
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        mockEntity = nil
        testScheduler = nil
        viewModel = nil
        fakeStore = nil
        super.tearDown()
    }
    
    func test_searchButtonTap() {
        let tapObserver = testScheduler.createObserver(Bool.self)
        
        viewModel
            .outputs
            .searchRequestObservable
            .flatMap { _ -> Observable<Bool> in .just(true) }
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
        
        viewModel.searchButtonTap.accept(())
        
        XCTAssertRecordedElements(tapObserver.events, [true])
    }
    
    func test_items_empty() {
        let itemsObserver = testScheduler.createObserver([Bool].self)
        
        viewModel
            .outputs
            .items
            .map { _ -> [Bool] in [true]}
            .asObservable()
            .bind(to: itemsObserver)
            .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemsObserver.events, [[true]])
    }
    
    func test_items_filled() {
        fakeStore.beforeNowMemories.accept([.init(value: .init())])
        viewModel = MemoryCollectionViewModel(memoryStore: fakeStore)
        
        let itemsObserver = testScheduler.createObserver([Bool].self)
        
        viewModel
            .outputs
            .items
            .map { _ -> [Bool] in [true]}
            .asObservable()
            .bind(to: itemsObserver)
            .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemsObserver.events, [[true]])
    }
    

}

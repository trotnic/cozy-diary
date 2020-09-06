//
//  TagsListViewModelType.swift
//  CozyTests
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import Cozy

class TagsListViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    var testScheduler: TestScheduler!
    var viewModel: TagsListViewModel!
    var tagManager: TagManager!
    var mockMemory: Memory!
    var fakeMemoryStore: FakeMemoryStore!
    
    override func setUpWithError() throws {
        super.setUp()
        disposeBag = DisposeBag()
        testScheduler = .init(initialClock: 0)
        mockMemory = Memory(
            date: Date(),
            index: 0,
            texts: [],
            photos: [],
            graffities: [],
            voices: [],
            tags: []
        )
        tagManager = .init(with: mockMemory)
        fakeMemoryStore = .init()
        viewModel = .init(manager: tagManager, memoryStore: fakeMemoryStore)
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        testScheduler = nil
        super.tearDown()
    }
    
    func test_tagInsert() {
        let itemsObserver = testScheduler.createObserver([String].self)
        let sampleItems = ["tag"]
        
        viewModel
            .inputs
            .tagInsert
            .accept("tag")
        
        tagManager
            .currentTags()
            .flatMap { (tags) -> Observable<[String]> in
                .just(tags.map { $0.rawValue })
            }
            .bind(to: itemsObserver)
            .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemsObserver.events, [sampleItems])
    }
    
    func test_tagRemove() {
        let itemsObserver = testScheduler.createObserver([String].self)
        let sampleItems = [String]()
        
        viewModel
            .inputs
            .tagInsert
            .accept("tag")
        
        viewModel
            .inputs
            .tagRemove
            .accept("tag")
        
        tagManager
            .currentTags()
            .flatMap { (tags) -> Observable<[String]> in
                .just(tags.map { $0.rawValue })
            }
            .bind(to: itemsObserver)
            .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemsObserver.events, [sampleItems])
    }
    
    func test_itemsFilled() {
        let itemsObserver = testScheduler.createObserver([String].self)
        let sampleItems = ["tag"]
        
        viewModel
            .inputs
            .tagInsert
            .accept("tag")
        
        viewModel
            .outputs
            .items
            .bind(to: itemsObserver)
            .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemsObserver.events, [sampleItems])
    }

}

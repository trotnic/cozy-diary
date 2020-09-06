//
//  TagManagerTests.swift
//  CozyTests
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import RxTest

@testable import Cozy

class TagManagerTests: XCTestCase {

    var disposeBag: DisposeBag!
    var manager: TagManager!
    var testScheduler: TestScheduler!
    var mockEntity: Memory!
    
    override func setUpWithError() throws {
        super.setUp()
        disposeBag = DisposeBag()
        mockEntity = .init()
        testScheduler = TestScheduler(initialClock: 0)
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        manager = nil
        mockEntity = nil
        testScheduler = nil
        super.tearDown()
    }

    func test_objectBinding() {
        manager = TagManager(with: mockEntity)
        XCTAssertNotNil(manager.currentItem)
    }
    
    func test_currentTags() {
        manager = TagManager(with: mockEntity)
        manager.insertTag("Tag")
        
        let sampleItems: [Tag<Memory>] = [.init(rawValue: "Tag")]
        
        let itemsObserver = testScheduler.createObserver([Tag<Memory>].self)
        
        manager.currentTags()
            .bind(to: itemsObserver)
        .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemsObserver.events, [sampleItems])
    }
    
    func test_removeTags() {
        mockEntity.tags = [.init(rawValue: "Tag")]
        manager = TagManager(with: mockEntity)
        manager.removeTag("Tag")
        
        let sampleItems: [Tag<Memory>] = []
        let itemsObserver = testScheduler.createObserver([Tag<Memory>].self)
        
        manager.currentTags()
            .bind(to: itemsObserver)
        .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemsObserver.events, [sampleItems])
    }
    
    func test_currentItem() {
        manager = TagManager(with: mockEntity)
        XCTAssertEqual(manager.currentItem()?.date, mockEntity.date)
    }
    
}

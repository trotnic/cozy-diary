//
//  MemoryEditViewModelTests.swift
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

class MemoryEditViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    var testScheduler: TestScheduler!
    var fakeMemoryStore: FakeMemoryStore!
    var mockMemory: Memory!
    var viewModel: MemoryEditViewModel!
    var mockBehavior: BehaviorRelay<Memory>!
    
    override func setUpWithError() throws {
        super.setUp()
        disposeBag = DisposeBag()
        testScheduler = .init(initialClock: 1)
        mockMemory = Memory(
            date: Date(),
            index: 0,
            texts: [],
            photos: [],
            graffities: [],
            voices: [],
            tags: []
        )
        fakeMemoryStore = FakeMemoryStore()
        mockBehavior = .init(value: mockMemory)
        viewModel = .init(memory: mockBehavior, memoryStore: fakeMemoryStore)
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        testScheduler = nil
        fakeMemoryStore = nil
        mockBehavior = nil
        mockMemory = nil
        viewModel = nil
        super.tearDown()
    }
    
    func test_seekForMemory() {
        
        viewModel
            .inputs
            .viewWillAppear
            .accept(())
        
        XCTAssertFalse(fakeMemoryStore.seekBag.isEmpty)
    }
    
    func test_leaveAwayMemory() {
        fakeMemoryStore.seekBag[mockMemory.date] = mockBehavior
        
        viewModel
            .inputs
            .viewWillDisappear
            .accept(())
        
        XCTAssertTrue(fakeMemoryStore.seekBag.isEmpty)
    }
    
    func test_removeMemory() {
        fakeMemoryStore.seekBag[mockMemory.date] = mockBehavior
        
        viewModel
            .inputs
            .deleteMemoryButtonTap
            .accept(())
        
        XCTAssertTrue(fakeMemoryStore.isCalled)
    }
    
    func test_reinitMemory() {
        
        viewModel
            .inputs
            .provideMemory
            .accept(mockBehavior)
        
        XCTAssertFalse(fakeMemoryStore.seekBag.isEmpty)
    }
    
    func test_textChunkAdd() {
        
        viewModel
            .inputs
            .textChunkAdd
            .accept(())
        
        XCTAssertEqual(mockBehavior.value.texts.count, 1)
    }
    
    func test_graffitiInsertCount() {
        
        let sampleData = Data()
        
        viewModel
            .inputs
            .graffitiInsertResponse(sampleData)
        
        XCTAssertEqual(mockBehavior.value.graffities.count, 1)
    }
    
    func test_graffitiInsertData() {
        
        let sampleData = Data()
        
        viewModel
            .inputs
            .graffitiInsertResponse(sampleData)
        
        XCTAssertEqual(mockBehavior.value.graffities.first?.graffiti, sampleData)
    }
    
    func test_photoInsertCount() {
        
        let url = URL(string: "someurl")
        let originalData = Data()
        let sampleData = ImageMeta(imageUrl: url, originalImage: originalData)
        
        viewModel
            .inputs
            .photoInsertResponse(sampleData)
        
        XCTAssertEqual(mockBehavior.value.photos.count, 1)
    }
    
    func test_photoInsertData() {
        
        let url = URL(string: "someurl")
        let originalData = Data()
        let sampleData = ImageMeta(imageUrl: url, originalImage: originalData)
        
        viewModel
            .inputs
            .photoInsertResponse(sampleData)
        
        XCTAssertEqual(mockBehavior.value.photos.first?.photo, originalData)
    }
    
    func test_voiceChunkAddTap() {
        
        let tapObserver = testScheduler.createObserver(Bool.self)
        
        viewModel
            .outputs
            .voiceInsertRequestObservable
            .flatMap { _ -> Observable<Bool> in .just(true) }
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
        
        viewModel
            .inputs
            .voiceChunkAdd
            .accept(())
        
        XCTAssertRecordedElements(tapObserver.events, [true])
        
    }
    
    
}

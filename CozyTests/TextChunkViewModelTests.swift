//
//  TextChunkViewModelTests.swift
//  CozyTests
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import Cozy

class TextChunkViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    var testScheduler: TestScheduler!
    var viewModel: TextChunkViewModel!
    var mockChunk: TextChunk!
    
    override func setUpWithError() throws {
        super.setUp()
        disposeBag = DisposeBag()
        testScheduler = .init(initialClock: 1)
        mockChunk = .init(text: .init(string: "text"), index: 1)
        viewModel = .init(mockChunk)
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        testScheduler = nil
        super.tearDown()
    }
    
    func test_text() {
        let itemObserver = testScheduler.createObserver([String].self)
        let sampleItems = ["text"]
        
        viewModel
            .outputs
            .text
            .map { [$0.string] }
            .bind(to: itemObserver)
            .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemObserver.events, [sampleItems])
    }
    
    func test_removeTap() {
        let tapObserver = testScheduler.createObserver(Bool.self)
        
        viewModel
            .outputs
            .removeTextRequest
            .flatMap { _ -> Observable<Bool> in .just(true) }
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
        
        viewModel
            .inputs
            .contextRemoveTap
            .accept(())
        
        XCTAssertRecordedElements(tapObserver.events, [true])
    }

}

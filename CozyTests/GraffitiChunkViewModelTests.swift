//
//  GraffitiChunkViewModelTests.swift
//  CozyTests
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import Cozy

class GraffitiChunkViewModelTests: XCTestCase {

    var disposeBag: DisposeBag!
    var testScheduler: TestScheduler!
    var viewModel: GraffitiChunkViewModel!
    var mockChunk: GraffitiChunk!

    override func setUpWithError() throws {
        super.setUp()
        disposeBag = DisposeBag()
        testScheduler = .init(initialClock: 1)
        mockChunk = .init(graffiti: Data(), index: 1)
        viewModel = .init(mockChunk)
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        testScheduler = nil
        viewModel = nil
        mockChunk = nil
        super.tearDown()
    }
    
    func test_graffiti() {
        let itemObserver = testScheduler.createObserver(Data.self)
        
        viewModel
            .outputs
            .graffiti
            .bind(to: itemObserver)
            .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemObserver.events, [mockChunk.graffiti])
    }
    
    
    func test_shareTap() {
        let tapObserver = testScheduler.createObserver(Bool.self)
        
        viewModel
            .outputs
            .shareItem
            .flatMap { _ -> Observable<Bool> in .just(true) }
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
        
        viewModel
            .inputs
            .shareButtonTap
            .accept(())
        
        XCTAssertRecordedElements(tapObserver.events, [true])
    }
    
    func test_copyTap() {
        let tapObserver = testScheduler.createObserver(Bool.self)
        
        viewModel
            .outputs
            .copyItem
            .flatMap { _ -> Observable<Bool> in .just(true) }
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
        
        viewModel
            .inputs
            .copyButtonTap
            .accept(())
        
        XCTAssertRecordedElements(tapObserver.events, [true])
    }
    
    func test_removeTap() {
        let tapObserver = testScheduler.createObserver(Bool.self)
        
        viewModel
            .outputs
            .removeItem
            .flatMap { _ -> Observable<Bool> in .just(true) }
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
        
        viewModel
            .inputs
            .removeButtonTap
            .accept(())
        
        XCTAssertRecordedElements(tapObserver.events, [true])
    }
    
}

//
//  GraffitiCreateViewModelTests.swift
//  CozyTests
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import Cozy

class GraffitiCreateViewModelTests: XCTestCase {

    var disposeBag: DisposeBag!
    var viewModel: GraffitiCreateViewModel!
    var testScheduler: TestScheduler!
    
    override func setUpWithError() throws {
        super.setUp()
        disposeBag = DisposeBag()
        testScheduler = .init(initialClock: 0)
        viewModel = .init()
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        testScheduler = nil
        viewModel = nil
        super.tearDown()
    }
    
    func test_closeButtonTap() {
        let tapObserver = testScheduler.createObserver(Bool.self)
        
        viewModel
            .outputs
            .closeRequestObservable
            .flatMap { _ -> Observable<Bool> in .just(true) }
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
        
        viewModel
            .inputs
            .closeButtonTap
            .accept(())
        
        XCTAssertRecordedElements(tapObserver.events, [true])
    }
    
    func test_saveButtonTap() {
        let tapObserver = testScheduler.createObserver(Bool.self)
        
        viewModel
            .outputs
            .saveRequestObservable
            .flatMap { _ -> Observable<Bool> in .just(true) }
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
        
        viewModel
            .inputs
            .saveButtonTap
            .accept(Data())
        
        XCTAssertRecordedElements(tapObserver.events, [true])
    }
    
    func test_dataTransition() {
        let tapObserver = testScheduler.createObserver(Data.self)
        let mockObject = Data()
        
        viewModel
            .outputs
            .saveRequestObservable
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
        
        viewModel
            .inputs
            .saveButtonTap
            .accept(mockObject)
        
        XCTAssertRecordedElements(tapObserver.events, [mockObject])
    }
}

//
//  LocalImageDetailViewModelTests.swift
//  CozyTests
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import Cozy

class LocalImageDetailViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    var viewModel: LocalImageDetailViewModel!
    var testScheduler: TestScheduler!
    
    override func setUpWithError() throws {
        super.setUp()
        disposeBag = DisposeBag()
        testScheduler = TestScheduler(initialClock: 0)
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        viewModel = nil
        testScheduler = nil
        super.tearDown()
    }
    
    func test_initializer() {
        let testData = Data()
        let itemObserver = testScheduler.createObserver(Data.self)
        
        viewModel = .init(image: testData)
        
        viewModel
            .outputs
            .image
            .bind(to: itemObserver)
            .disposed(by: disposeBag)
        
        XCTAssertRecordedElements(itemObserver.events, [testData])
    }
    
    func test_closeButtonTap() {
        viewModel = .init(image: Data())
        
        let tapObserver = testScheduler.createObserver(Bool.self)
        
        viewModel
            .outputs
            .closeRequestObservable
            .flatMap { _ -> Observable<Bool> in .just(true)}
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
        
        viewModel
            .inputs
            .closeButtonTap
            .accept(())
        
        XCTAssertRecordedElements(tapObserver.events, [true])
    }
    
    func test_moreButtontap() {
        viewModel = .init(image: Data())
        
        let tapObserver = testScheduler.createObserver(Bool.self)
        
        viewModel
            .outputs
            .moreRequestObservable
            .flatMap { _ -> Observable<Bool> in .just(true)}
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
        
        viewModel
            .inputs
            .moreButtonTap
            .accept(())
        
        XCTAssertRecordedElements(tapObserver.events, [true])
    }
    
}

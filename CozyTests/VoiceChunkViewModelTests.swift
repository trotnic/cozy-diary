//
//  VoiceChunkViewModelTests.swift
//  CozyTests
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import Cozy

class VoiceChunkViewModelTests: XCTestCase {

    var disposeBag: DisposeBag!
    var testScheduler: TestScheduler!
    
    override func setUpWithError() throws {
        super.setUp()
        disposeBag = DisposeBag()
        testScheduler = .init(initialClock: 1)
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        testScheduler = nil
        super.tearDown()
    }
}

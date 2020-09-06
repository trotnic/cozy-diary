//
//  VoiceChunkManagerTests.swift
//  CozyTests
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import Cozy

class VoiceChunkManagerTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    var manager: VoiceChunkManager!
    var testScheduler: TestScheduler!
    
    override func setUpWithError() throws {
        super.setUp()
        disposeBag = DisposeBag()
        manager = VoiceChunkManager()
        testScheduler = TestScheduler(initialClock: 0)
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        manager = nil
        testScheduler = nil
        super.tearDown()
    }

    func test_insert() {
        let sampleUrl = URL(string: "someurl")!
        
        let itemObserver = testScheduler.createObserver(URL.self)
        
        manager
            .voiceFileUrl
            .bind(to: itemObserver)
            .disposed(by: disposeBag)
        
        manager.insertVoiceFileUrl(sampleUrl)
        
        XCTAssertRecordedElements(itemObserver.events, [sampleUrl])
    }

}

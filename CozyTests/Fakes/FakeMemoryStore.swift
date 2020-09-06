//
//  FakeMemoryStore.swift
//  CozyTests
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import RxSwift
import RxTest
import RxCocoa

@testable import Cozy

class FakeMemoryStore: MemoryStoreType {
    var isCalled: Bool = false
    var seekBag: [Date: BehaviorRelay<Memory>] = [:]
    var allMemories: BehaviorRelay<[BehaviorRelay<Memory>]> = .init(value: [])
    var beforeNowMemories: BehaviorRelay<[BehaviorRelay<Memory>]> = .init(value: [])
    
    let relevantMemory = BehaviorRelay<Memory>(value: .init())
    
    func fetchAll() -> Observable<[BehaviorRelay<Memory>]> { allMemories.asObservable() }
    
    func fetchBeforeNow() -> Observable<[BehaviorRelay<Memory>]> { beforeNowMemories.asObservable() }
    
    func addItem(_ memory: Memory) -> Bool {
        isCalled = true
        return true
    }
    
    func updateItem(_ memory: Memory) -> Bool {
        isCalled = true
        return true
    }
    
    func removeItem(_ memory: Memory) -> Bool {
        isCalled = true
        return true
    }
    
    func seekFor(_ memory: BehaviorRelay<Memory>, key: Date) { seekBag[key] = memory }
    
    func leaveAway(key: Date) { seekBag[key] = nil }
}

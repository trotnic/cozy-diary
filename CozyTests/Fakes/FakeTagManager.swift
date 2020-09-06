//
//  FakeTagManager.swift
//  CozyTests
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift

@testable import Cozy

final class FakeTagManager: TagManagerType {
    var memory: Memory
    
    required init(with taggable: Memory) {
        self.memory = taggable
    }
    
    func insertTag(_ tag: String) { memory.tags.append(.init(rawValue: tag)) }
    
    func removeTag(_ tag: String) { memory.tags = memory.tags.filter { $0.rawValue != tag } }
    
    func currentTags() -> Observable<Memory.Tags> { .just(memory.tags) }
    
    func currentItem() -> Memory? { memory }
    
    typealias Item = Memory
    
}


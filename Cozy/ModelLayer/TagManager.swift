//
//  TagManager.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/1/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift


protocol TagManagerType {
    associatedtype Item: Taggable
    
    init(with taggable: Item)
    
    func insertTag(_ tag: String)
    func removeTag(_ tag: String)
    func currentTags() -> Observable<Item.Tags>
    func currentItem() -> Item?
}

final class TagManager: TagManagerType {
    typealias Item = Memory
    
    private var taggable: BehaviorSubject<Item>
    
    required init(with taggable: Item) {
        self.taggable = .init(value: taggable)
    }
    
    func insertTag(_ tag: String) {
        if let value = try? taggable.value() {
            value.tags.append(.init(rawValue: tag))
            taggable.onNext(value)
        }        
    }
    
    func removeTag(_ tag: String) {
        if let value = try? taggable.value() {
            value.tags = value.tags.filter { $0.rawValue.lowercased() != tag.lowercased() }
            taggable.onNext(value)
        }
    }
    
    func currentTags() -> Observable<Item.Tags> { taggable.flatMap{ item -> Observable<Item.Tags> in .just(item.tags)} }
    
    func currentItem() -> Item? { try? taggable.value() }
    
}

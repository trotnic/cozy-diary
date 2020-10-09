//
//  MemoryFactory.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 10/9/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation

protocol MemoryFactoryType {
    func createByDate(_ date: Date)
}

class MemoryFactory: MemoryFactoryType {
    let store: MemoryStoreType
    
    init(store: MemoryStoreType) {
        self.store = store
    }
    
    func createByDate(_ date: Date) {
        store.addItem(.init(date: date, index: 1, texts: [], photos: [], graffities: [], voices: [], tags: []))
    }
}

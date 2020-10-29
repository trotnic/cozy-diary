//
//  MemoryStoreType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 10/29/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift


protocol MemoryStoreType {
    // CoreData Accessor
    var relevantMemory: BehaviorRelay<Memory> { get }
    var allObjects: Observable<[BehaviorRelay<Memory>]> { get }
    
    func addItem(_ memory: Memory)
    func updateItem(_ memory: Memory)
    func removeItem(_ memory: Memory)
    
    // Object Synchronizer
    func remember(_ memory: BehaviorRelay<Memory>, key: Date)
    func forget(key: Date)
}

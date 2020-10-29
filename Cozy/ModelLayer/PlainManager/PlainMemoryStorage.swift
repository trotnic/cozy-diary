//
//  PlainMemoryStore.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 10/29/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift


class PlainMemoryStorage {
    var relevantMemory: BehaviorRelay<Memory> {
        allPublisher.value
            .filter({ $0.value.date == self.calendar.today })
            .first ?? .init(value: .init())
    }
    
    var allObjects: Observable<[BehaviorRelay<Memory>]> { allPublisher.asObservable() }
        
    private let allPublisher: BehaviorRelay<[BehaviorRelay<Memory>]> = .init(value: [])
    private let accessor: CoreDataAccessor
    private let calendar: CalendarType
    
    private var blackDayBag: [Date: BehaviorRelay<Memory>] = [:]
    
    init(accessor: CoreDataAccessor, calendar: CalendarType) {
        self.accessor = accessor
        self.calendar = calendar
        fetch()
    }
    
    private func fetch() { fetch(completion: nil) }
    
    private func fetch(completion: (() -> ())?) {
        accessor.all { [weak self] (result) in
            switch result {
            case .success(let objects):
                self?.allPublisher.accept(objects.map { BehaviorRelay(value: $0.selfChunk)} )
                completion?()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func processResult(_ result: Result<Void, Error>) {
        switch result {
        case .success():
            fetch()
        case .failure(let error):
            print(error)
        }
    }
}


extension PlainMemoryStorage: MemoryStoreType {
    func addItem(_ memory: Memory) {
        accessor.create(object: memory) { [weak self] (result) in
            self?.processResult(result)
        }
    }
    
    func updateItem(_ memory: Memory) {
        accessor.update(object: memory) { [weak self] (result) in
            self?.processResult(result)
        }
    }
    
    func removeItem(_ memory: Memory) {
        accessor.delete(object: memory) { [weak self] (result) in
            self?.processResult(result)
        }
    }
    
    func remember(_ memory: BehaviorRelay<Memory>, key: Date) {
        blackDayBag[key] = memory
    }
    
    func forget(key: Date) {
        if let memory = blackDayBag[key]?.value {
            updateItem(memory)
        }
        blackDayBag.removeValue(forKey: key)
    }
}

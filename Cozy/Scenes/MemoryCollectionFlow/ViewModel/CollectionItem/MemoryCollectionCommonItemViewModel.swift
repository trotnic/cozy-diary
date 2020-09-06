//
//  MemoryCollectionCommonItemViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class MemoryCollectionCommonItemViewModel: MemoryCollectionCommonItemViewModelType, MemoryCollectionCommonItemViewModelOutput, MemoryCollectionCommonItemViewModelInput {
    
    var outputs: MemoryCollectionCommonItemViewModelOutput { return self }
    var inputs: MemoryCollectionCommonItemViewModelInput { return self }
    
    // MARK: Outputs
    lazy var date: Observable<String> = {
        memory.map { (memory) -> String in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            let result = dateFormatter.string(from: memory.date)
            return result
        }
    }()
    
    lazy var text: Observable<String> = { memory.map { (memory) -> String in memory.texts.first?.text.string ?? "" } }()
    lazy var image: Observable<Data?> = { memory.map { (memory) -> Data? in memory.photos.first?.photo } }()
    
    var tapRequestObservable: Observable<Void> { tap.asObservable() }
    
    // MARK: Inputs
    let tap = PublishRelay<Void>()
    
    // MARK: Private
    private let memory: BehaviorRelay<Memory>
    
    
    init(memory: BehaviorRelay<Memory>) {
        self.memory = memory
    }
}

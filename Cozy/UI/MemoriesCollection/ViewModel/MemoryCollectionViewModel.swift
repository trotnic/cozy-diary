//
//  MemoryCollectionViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MemoryCollectionViewModel: MemoryCollectionViewModelType {
    
    var detailMemoryRequest: PublishRelay<Memory> = .init()
    
    private let disposeBag = DisposeBag()
    
    lazy var items: BehaviorRelay<[MemoryCollectionViewSection]> = {
        .init(value: [
            .init(items: CoreDataModeller(manager: CoreDataManager.shared)
                .fetchAllMemories()
                .map { memory -> MemoryCollectionViewItem in
                    let viewModel = MemoryCollectionCommonItemViewModel(memory: memory)
                    viewModel.cellReceiveTap.subscribe(onNext: { _ in
                        self.detailMemoryRequest.accept(memory)
                    }).disposed(by: self.disposeBag)
                    return .CommonItem(viewModel: viewModel)
                }
        )])
    }()

}


class MemoryCollectionCommonItemViewModel {
    private let memory: Memory
    
    var cellReceiveTap: PublishRelay<Void>
    
    var date: Observable<String> {
        .just("\(memory.date)")
    }
    
    init(memory: Memory) {
        self.memory = memory
        cellReceiveTap = .init()
    }
}

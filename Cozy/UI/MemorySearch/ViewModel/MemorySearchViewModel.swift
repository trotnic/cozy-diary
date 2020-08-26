//
//  MemorySearchViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/25/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol MemorySearchViewModelOutput {
    var closeObservable: Observable<Void> { get }
    
    var items: Driver<[MemoryCollectionViewSection]> { get }
}

protocol MemorySearchViewModelInput {
    var closeRequest: () -> () { get }
    
    var searchObserver: PublishRelay<String> { get }
}

protocol MemorySearchViewModelType {
    var outputs: MemorySearchViewModelOutput { get }
    var inputs: MemorySearchViewModelInput { get }
}

class MemorySearchViewModel: MemorySearchViewModelType, MemorySearchViewModelOutput, MemorySearchViewModelInput {
    
    var outputs: MemorySearchViewModelOutput { return self }
    var inputs: MemorySearchViewModelInput { return self }
    
    // MARK: Outputs
    var items: Driver<[MemoryCollectionViewSection]> {
        itemsPublisher.asDriver(onErrorJustReturn: [])
    }
    
    let closeObservable: Observable<Void>
    
    // MARK: Inputs
    lazy var closeRequest = { { self.closePublisher.onNext(()) } }()
    let searchObserver = PublishRelay<String>()
    
    
    // MARK: Private
    private let disposeBag = DisposeBag()
    private let closePublisher = PublishSubject<Void>()
    
    private let itemsPublisher = BehaviorRelay<[MemoryCollectionViewSection]>(value: [])
    
    private let memoryStore: MemoryStoreType
    
    // MARK: Init
    init(memoryStore: MemoryStoreType) {
        self.memoryStore = memoryStore
        
        closeObservable = closePublisher.asObservable()
        
        searchObserver
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .debounce(.microseconds(400), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (search) in
                    self.memoryStore.fetchObservables()
                    .map({ (memories) -> [MemoryCollectionViewSection] in
                        [
                            .init(items:
                                memories.filter({ (memory) -> Bool in
                                    memory.contains(term: search)
                                }).map({ (memory) -> MemoryCollectionViewItem in
                                    let viewModel = MemoryCollectionCommonItemViewModel(memory: memory)
                                    return .CommonItem(viewModel: viewModel)
                                })
                            )
                        ]
                    })
                    .subscribe(onNext: { (result) in
                        self.itemsPublisher.accept(result)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
//        memoryStore.fetchObservables()
//            .map { memories -> [MemoryCollectionViewSection] in
//                [.init(items: memories.map { memory -> MemoryCollectionViewItem in
//                    let viewModel = MemoryCollectionCommonItemViewModel(memory: memory)
//                    return .CommonItem(viewModel: viewModel)
//                })]
//        }
//        .subscribe(onNext: { [weak self] (section) in
//            self?.itemsPublisher.accept(section)
//        })
//        .disposed(by: disposeBag)
    }
}

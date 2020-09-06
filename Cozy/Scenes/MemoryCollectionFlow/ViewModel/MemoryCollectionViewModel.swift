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


class MemoryCollectionViewModel: MemoryCollectionViewModelType, MemoryCollectionViewModelOutput, MemoryCollectionViewModelInput {
    
    // MARK: Outputs & Inputs
    var outputs: MemoryCollectionViewModelOutput { return self }
    var inputs: MemoryCollectionViewModelInput { return self }
    
    // MARK: Outputs
    var items: Driver<[MemoryCollectionViewSection]> {
        itemsPublisher
            .map { [unowned self] memories -> [MemoryCollectionViewSection] in
                [.init(items: memories.map { memory -> MemoryCollectionViewItem in
                    
                    let viewModel = MemoryCollectionCommonItemViewModel(memory: memory)
                    
                    viewModel
                        .outputs
                        .tapRequestObservable
                        .subscribe(onNext: { [weak self] in
                            self?.detailRequestObserver.onNext(memory)
                        })
                        .disposed(by: self.disposeBag)
                    
                    return .CommonItem(viewModel: viewModel)
                })]
        }
        .asDriver(onErrorJustReturn: [])
    }
    
    var detailRequestObservable: Observable<BehaviorRelay<Memory>> { detailRequestObserver.asObservable() }
    var searchRequestObservable: Observable<Void> { searchButtonTap.asObservable() }
    
    // MARK: Inputs
    let searchButtonTap = PublishRelay<Void>()
    let viewWillAppear = PublishRelay<Void>()
        
    // MARK: Private
    private let disposeBag = DisposeBag()
    private let memoryStore: MemoryStoreType
    
    private let detailRequestObserver = PublishSubject<BehaviorRelay<Memory>>()
    private let itemsPublisher = BehaviorRelay<[BehaviorRelay<Memory>]>(value: [])
    
    // MARK: Init
    init(memoryStore: MemoryStoreType) {
        self.memoryStore = memoryStore
        
        memoryStore
            .fetchBeforeNow()
            .bind(to: itemsPublisher)
            .disposed(by: disposeBag)
    }
}


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

protocol MemoryCollectionViewModelOutput {
    var items: Driver<[MemoryCollectionViewSection]> { get }
    
    var detailRequestObservable: Observable<BehaviorRelay<Memory>> { get }
    var searchRequestObservable: Observable<Void> { get }
    
    
}

protocol MemoryCollectionViewModelInput {
    var searchRequest: () -> () { get }
    
    var viewWillAppear: PublishRelay<Void> { get }
}

protocol MemoryCollectionViewModelType {
    var outputs: MemoryCollectionViewModelOutput { get }
    var inputs: MemoryCollectionViewModelInput { get }
}

class MemoryCollectionViewModel: MemoryCollectionViewModelType, MemoryCollectionViewModelOutput, MemoryCollectionViewModelInput {
    
    var outputs: MemoryCollectionViewModelOutput { return self }
    var inputs: MemoryCollectionViewModelInput { return self }
    
    // MARK: Outputs
    var items: Driver<[MemoryCollectionViewSection]> {
        itemsPublisher
            .map { [unowned self] memories -> [MemoryCollectionViewSection] in
                [.init(items: memories.map { memory -> MemoryCollectionViewItem in
                    let viewModel = MemoryCollectionCommonItemViewModel(memory: memory)
                    viewModel.outputs.tapRequestObservable
                        .subscribe(onNext: { [weak self] in
                            self?.detailRequestPublisher.onNext(memory)
                        })
                        .disposed(by: self.disposeBag)
                    return .CommonItem(viewModel: viewModel)
                })]
        }
        .asDriver(onErrorJustReturn: [])
    }
    
    let detailRequestObservable: Observable<BehaviorRelay<Memory>>
    let searchRequestObservable: Observable<Void>
    
    // MARK: Inputs
    lazy var searchRequest = { { self.searchRequestPublisher.onNext(()) } }()
    
    let viewWillAppear = PublishRelay<Void>()
        
    // MARK: Private
    private let disposeBag = DisposeBag()
    private let memoryStore: MemoryStoreType
    
    private let detailRequestPublisher = PublishSubject<BehaviorRelay<Memory>>()
    private let searchRequestPublisher = PublishSubject<Void>()
    
    private let itemsPublisher = BehaviorRelay<[BehaviorRelay<Memory>]>(value: [])
    
    // MARK: Init
    init(memoryStore: MemoryStoreType) {
        self.memoryStore = memoryStore
        
        detailRequestObservable = detailRequestPublisher.asObservable()
        searchRequestObservable = searchRequestPublisher.asObservable()
        
        memoryStore.fetchBeforeNow()
            .bind(to: itemsPublisher)
            .disposed(by: disposeBag)
    }
}


// MARK: Collection Common Item View Model

protocol MemoryCollectionCommonItemViewModelOutput {
    var date: Observable<String> { get }
    var text: Observable<String> { get }
    var image: Observable<Data?> { get }
    
    var tapRequestObservable: Observable<Void> { get }
}

protocol MemoryCollectionCommonItemViewModelInput {
    var tapRequest: () -> () { get }
}

protocol MemoryCollectionCommonItemViewModelType {
    var outputs: MemoryCollectionCommonItemViewModelOutput { get }
    var inputs: MemoryCollectionCommonItemViewModelInput { get }
}

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
    
    lazy var text: Observable<String> = {
        memory.map { (memory) -> String in
            memory.texts.first?.text.string ?? ""
        }
    }()
    
    lazy var image: Observable<Data?> = {
        memory.map({ (memory) -> Data? in
            memory.photos.first?.photo
        })
    }()
    
    var tapRequestObservable: Observable<Void>
    
    // MARK: Inputs
    lazy var tapRequest = { { self.tapRequestPublisher.onNext(()) } }()
    
    // MARK: Private
    private let memory: BehaviorRelay<Memory>
    
    private let tapRequestPublisher = PublishSubject<Void>()
    
    
    init(memory: BehaviorRelay<Memory>) {
        self.memory = memory
        
        tapRequestObservable = tapRequestPublisher.asObservable()
    }
}

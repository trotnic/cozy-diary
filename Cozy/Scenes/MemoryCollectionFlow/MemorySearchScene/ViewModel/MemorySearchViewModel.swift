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
    var items: Driver<[MemoryCollectionViewSection]> { get }
    
    var dismissCurrentController: Observable<Void> { get }
    var showFilter: Observable<FilterManagerType> { get }
    var showDetail: Observable<BehaviorRelay<Memory>> { get }
}

protocol MemorySearchViewModelInput {
    var searchButtonTap: PublishRelay<Void> { get }
    
    var searchObserver: PublishRelay<String> { get }
    var searchCancelObserver: PublishRelay<Void> { get }
    
    var filterButtonTap: PublishRelay<Void> { get } // some service as pushed object
    var closeButtonTap: PublishRelay<Void> { get }
    var didSelectItem: PublishRelay<BehaviorRelay<Memory>> { get }
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

        filteredPublisher
            .map { [unowned self] memories -> [MemoryCollectionViewSection] in
                [.init(items: memories.map { memory -> MemoryCollectionViewItem in
                    let viewModel = MemoryCollectionCommonItemViewModel(memory: memory)
                    viewModel.outputs.tapRequestObservable
                        .subscribe(onNext: { [weak self] in
                            self?.inputs.didSelectItem.accept(memory)
                        })
                        .disposed(by: self.disposeBag)
                    return .CommonItem(viewModel: viewModel)
                })]
        }
        .asDriver(onErrorJustReturn: [])
    }
    
    // MARK: Coordinator output
    var showFilter: Observable<FilterManagerType> {
        filterButtonTap.flatMap { [unowned self] (_) -> Observable<FilterManagerType> in
            .just(self.filterManager)
        }
    }
    var showDetail: Observable<BehaviorRelay<Memory>> { didSelectItem.asObservable() }
    var dismissCurrentController: Observable<Void> { closeButtonTap.asObservable() }
    
    // MARK: Inputs
    let filterButtonTap = PublishRelay<Void>()
    let closeButtonTap = PublishRelay<Void>()
    let didSelectItem = PublishRelay<BehaviorRelay<Memory>>()
    
    let searchButtonTap = PublishRelay<Void>()
    
    let searchObserver = PublishRelay<String>()
    let searchCancelObserver = PublishRelay<Void>()
    
    // MARK: Private
    private let disposeBag = DisposeBag()
    private let closePublisher = PublishSubject<Void>()
    
    private let itemsPublisher = BehaviorRelay<[BehaviorRelay<Memory>]>(value: [])
    private let filteredPublisher = BehaviorRelay<[BehaviorRelay<Memory>]>(value: [])
    
    private let memoryStore: MemoryStoreType
    
    private let filterManager: FilterManagerType
    
    // MARK: Init
    init(memoryStore: MemoryStoreType, filterManager: FilterManagerType) {
        self.memoryStore = memoryStore
        self.filterManager = filterManager
        
        memoryStore.fetchBeforeNow()
            .bind(onNext: { [weak self] (memories) in
                self?.itemsPublisher.accept(memories)                
                self?.filterManager.refillInitialFiltersWith(
                    memories.map { $0.value }
                        .allTags.map { tag -> Filter in .tag(tag.rawValue) }
                )
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(searchObserver, filterManager.selectedFiltersObservable())
            .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
            .map({ [unowned self] (term, filters) -> ([BehaviorRelay<Memory>], Set<Filter>) in
                return (self.itemsPublisher
                        .value
                    .filter {term.isEmpty ? true : $0.value.contains(term: term)
                    }, filters)
            })
            .map { (memories, filters) -> ([BehaviorRelay<Memory>], Array<String>, Array<Int>) in
                var tags = [String]()
                var months = [Int]()
                filters.forEach { (filter) in
                    switch filter {
                    case let .tag(value):
                        tags.append(value)
                    case let .date(month):
                        switch month {
                        case let .january(_, num),
                            let .february(_, num),
                            let .march(_, num),
                            let .april(_, num),
                            let .may(_, num),
                            let .june(_, num),
                            let .july(_, num),
                            let .august(_, num),
                            let .september(_, num),
                            let .october(_, num),
                            let .november(_, num),
                            let .december(_, num):
                            months.append(num)
                        }
                    }
                }
                return (memories, tags, months)
            }
            .map { (memories, tags, months) -> ([BehaviorRelay<Memory>], Array<Int>) in
                var probableResult = memories
                
                tags.forEach { (tag) in
                    probableResult = probableResult.filter { $0.value.taggedWith(term: tag) }
                }
                
                return (probableResult, months)
            }
            .map({ (memories, months) -> [BehaviorRelay<Memory>] in
                var probableResult = memories
                
                months.forEach { (month) in
                    probableResult = probableResult.filter { Calendar.current.component(.month, from: $0.value.date) == month}
                }
                
                return probableResult
            })
            .flatMap { (memories) -> Observable<[BehaviorRelay<Memory>]> in
                .just(memories)
            }
            .bind(to: filteredPublisher)
            .disposed(by: disposeBag)
            
        
        searchCancelObserver
            .subscribe(onNext: { [weak self] in
                if let self = self {
                    self.filteredPublisher.accept(self.itemsPublisher.value)
                }
            })
        .disposed(by: disposeBag)
    }
}

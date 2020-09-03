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
            .map { (memories, filters) -> ([BehaviorRelay<Memory>], Array<String>) in
                var tags: [String] = []
                filters.forEach { (filter) in
                    switch filter {
                    case let .tag(value):
                        tags.append(value)
                    default:
                        return
                    }
                }
                return (memories, tags)
            }
            .map { (memories, tags) -> [BehaviorRelay<Memory>] in
                var probableResult = memories
                
                tags.forEach { (tag) in
                    probableResult = probableResult.filter { $0.value.taggedWith(term: tag) }
                }
                
                return probableResult
            }
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

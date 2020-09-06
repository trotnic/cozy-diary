//
//  MemorySearchFilterViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/2/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa



class MemorySearchFilterViewModel: MemorySearchFilterViewModelType, MemorySearchFilterViewModelOutput, MemorySearchFilterViewModelInput {
    
    // MARK: Outputs & Inputs
    var outputs: MemorySearchFilterViewModelOutput { return self }
    var inputs: MemorySearchFilterViewModelInput { return self }
    
    // MARK: Outputs
    var items: Observable<[MemorySearchFilterCollectionSection]> {
        itemsObserver.asObservable()
    }
    
    // MARK: Inputs
    let cancelButtonTap = PublishRelay<Void>()
    let clearButtonTap = PublishRelay<Void>()
    
    // MARK: Private
    private let manager: FilterManagerType
    private let disposeBag = DisposeBag()
    
    private let itemsObserver = BehaviorRelay<[MemorySearchFilterCollectionSection]>(value: [])
    
    
    // MARK: Init
    init(manager: FilterManagerType) {
        self.manager = manager
        fillFilters()
        setupInputs()
    }
    
    private func fillFilters() {
        
        let allFilters = manager.allFilters()
        let selectedFilters = manager.currentFilters()
        
        var tags = [TagModel]()
        var months = [MonthModel]()
                        
        selectedFilters.forEach { (filter) in
            switch filter {
            case let .tag(value):
                tags.append(.init(value: value, isSelected: true))
            case let .date(month):
                months.append(.init(value: month, isSelected: true))
            }
        }
        
        let allOthers = allFilters.subtracting(selectedFilters)
        
        allOthers.forEach { (filter) in
            switch filter {
            case let .tag(value):
                tags.append(.init(value: value))
            case let .date(month):
                months.append(.init(value: month))
            }
        }
        
        
        let tagsViewModel = MemorySearchFilterTagsViewModel(tags: tags)
        
        tagsViewModel
            .outputs
            .appendItem
            .subscribe(onNext: { [weak self] (tag) in
                self?.manager.insertFilter(.tag(tag.value))
            })
            .disposed(by: self.disposeBag)
        
        tagsViewModel
            .outputs
            .removeItem
            .subscribe(onNext: { [weak self] (tag) in
                self?.manager.removeFilter(.tag(tag.value))
            })
            .disposed(by: self.disposeBag)
        
        
        let monthsViewModel = MemorySearchFilterMonthsViewModel(months: months)
        
        monthsViewModel
            .outputs
            .appendItem
            .subscribe(onNext: { [weak self] (month) in
                self?.manager.insertFilter(.date(month.value))
            })
            .disposed(by: self.disposeBag)
        
        monthsViewModel
            .outputs
            .removeItem
            .subscribe(onNext: { [weak self] (month) in
                self?.manager.removeFilter(.date(month.value))
            })
            .disposed(by: self.disposeBag)
        
        let result: [MemorySearchFilterCollectionSection] = [
            .init(items: [.tagsItem(viewModel: tagsViewModel)]),
            .init(items: [.monthsItem(viewModel: monthsViewModel)])
        ]
        
        itemsObserver.accept(result)
    }
    
    private func setupInputs() {
        clearButtonTap
            .subscribe(onNext: { [weak self] (_) in
                self?.manager.clearFilters()
            })
            .disposed(by: disposeBag)
    }
}


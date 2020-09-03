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

class TagModel {
    var isSelected: Bool
    let value: String
    
    init(value: String, isSelected: Bool = false) {
        self.value = value
        self.isSelected = isSelected
    }
}

class MemorySearchFilterViewModel: MemorySearchFilterViewModelType, MemorySearchFilterViewModelOutput, MemorySearchFilterViewModelInput {
    
    // MARK: Outputs & Inputs
    var outputs: MemorySearchFilterViewModelOutput { return self }
    var inputs: MemorySearchFilterViewModelInput { return self }
    
    // MARK: Outputs
    var items: Observable<[MemorySearchFilterCollectionSection]> {
        itemsObserver.asObservable()
    }
    
    // MARK: Inputs
    
    // MARK: Private
    private let manager: FilterManagerType
    private let disposeBag = DisposeBag()
    
    private let itemsObserver = BehaviorRelay<[MemorySearchFilterCollectionSection]>(value: [])
    
    
    // MARK: Init
    init(manager: FilterManagerType) {
        self.manager = manager
        fillFilters()
    }
    
    private func fillFilters() {
        let allFilters = manager.allFilters()
        let selectedFilters = manager.currentFilters()
        
        var tags: [TagModel] = []
                        
        selectedFilters.forEach { (filter) in
            switch filter {
            case let .tag(value):
                tags.append(.init(value: value, isSelected: true))
            default:
                return
            }
        }
        
        let allOthers = allFilters.subtracting(selectedFilters)
        
        allOthers.forEach { (filter) in
            switch filter {
            case let .tag(value):
                tags.append(.init(value: value))
            default:
                return
            }
        }
        
        let tagsViewModel = MemorySearchFilterTagsViewModel(tags: tags)
        
        tagsViewModel.outputs.appendItem
            .subscribe(onNext: { [weak self] (tag) in
                self?.manager.insertFilter(.tag(tag.value))
            })
            .disposed(by: self.disposeBag)
        
        tagsViewModel.outputs.removeItem
            .subscribe(onNext: { [weak self] (tag) in
                self?.manager.removeFilter(.tag(tag.value))
            })
            .disposed(by: self.disposeBag)
        
        let result: [MemorySearchFilterCollectionSection] = [.init(items: [.tagsItem(viewModel: tagsViewModel)])]
        itemsObserver.accept(result)
    }
}


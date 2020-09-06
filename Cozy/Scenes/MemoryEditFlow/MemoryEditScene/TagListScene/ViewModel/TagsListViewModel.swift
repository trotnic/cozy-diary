//
//  TagsListViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/1/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class TagsListViewModel: TagsListViewModelType, TagsListViewModelOutput, TagsListViewModelInput {
    
    // MARK: Outputs & Inputs
    var outputs: TagsListViewModelOutput { return self }
    var inputs: TagsListViewModelInput { return self }
    
    // MARK: Outputs
    var items: Observable<[String]> {
        manager.currentTags()
            .flatMap { (tags) -> Observable<[String]> in
                .just(tags.map { $0.rawValue })
        }   
    }
    
    // MARK: Inputs
    let tagInsert = PublishRelay<String>()
    let tagRemove = PublishRelay<String>()
    let dismiss = PublishRelay<Void>()
    
    // MARK: Private
    private let disposeBag = DisposeBag()
    private let manager: TagManager
    private let memoryStore: MemoryStoreType
    
    // MARK: Init
    init(manager: TagManager, memoryStore: MemoryStoreType) {
        self.manager = manager
        self.memoryStore = memoryStore
        
        setupInputs()
    }
    
    // MARK: Private methods
    private func setupInputs() {
        tagInsert
            .filter{ !$0.isEmpty }
            .subscribe(onNext: { [weak self] (tag) in
                self?.manager.insertTag(tag.lowercased())
            })
            .disposed(by: disposeBag)
        
        tagRemove
            .subscribe(onNext: { [weak self] (tag) in
                self?.manager.removeTag(tag)
            })
            .disposed(by: disposeBag)        
        
        dismiss
            .subscribe(onNext: { [weak self] in
                guard let self = self, let memory = self.manager.currentItem() else { return }
                self.memoryStore.updateItem(memory)
            })
            .disposed(by: disposeBag)
    }
}

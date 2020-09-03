//
//  MemorySearchFilterTagsViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/2/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class MemorySearchFilterTagsViewModel: MemorySearchFilterTagsViewModelType, MemorySearchFilterTagsViewModelOutput, MemorySearchFilterTagsViewModelInput {
    
    
    // MARK: Outputs & Inputs
    var outputs: MemorySearchFilterTagsViewModelOutput { return self }
    var inputs: MemorySearchFilterTagsViewModelInput { return self }
    
    // MARK: Outputs
    var items: Observable<[BehaviorRelay<TagModel>]> {
        tags.asObservable()
    }
    
    var appendItem: Observable<TagModel> { addObserver.asObservable() }
    var removeItem: Observable<TagModel> { removeObserver.asObservable() }
    
    // MARK: Inputs
    
    // MARK: Private
    private let tags = BehaviorRelay<[BehaviorRelay<TagModel>]>(value: [])
    private let disposeBag = DisposeBag()
    
    private let addObserver = PublishRelay<TagModel>()
    private let removeObserver = PublishRelay<TagModel>()
    
    // MARK: Init
    init(tags: [TagModel]) {
        self.tags.accept(tags.map { [unowned self] item -> BehaviorRelay<TagModel> in
            let observer = BehaviorRelay<TagModel>(value: item)
            
            observer.subscribe(onNext: { [weak self] (model) in
                if model.isSelected {
                    self?.addObserver.accept(model)
                } else {
                    self?.removeObserver.accept(model)
                }
            })
            .disposed(by: self.disposeBag)
            
            return observer
        })
    }
}

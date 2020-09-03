//
//  MemorySearchFilterMonthsViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/3/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class MemorySearchFilterMonthsViewModel: MemorySearchFilterMonthsViewModelType, MemorySearchFilterMonthsViewModelOutput, MemorySearchFilterMonthsViewModelInput {
    
    // MARK: Outputs & Inputs
    var outputs: MemorySearchFilterMonthsViewModelOutput { return self }
    var inputs: MemorySearchFilterMonthsViewModelInput { return self }
    
    // MARK: Outputs
    
    var items: Observable<[BehaviorRelay<MonthModel>]> {
        months.asObservable()
    }
    
    var appendItem: Observable<MonthModel> { addObserver.asObservable() }
    var removeItem: Observable<MonthModel> { removeObserver.asObservable() }
    
    // MARK: Inputs
    
    // MARK: Private
    private let months = BehaviorRelay<[BehaviorRelay<MonthModel>]>(value: [])
    private let disposeBag = DisposeBag()
    
    private let addObserver = PublishRelay<MonthModel>()
    private let removeObserver = PublishRelay<MonthModel>()
    
    // MARK: Init
    init(months: [MonthModel]) {
        self.months.accept(months.map { [unowned self] item -> BehaviorRelay<MonthModel> in
            let observer = BehaviorRelay<MonthModel>(value: item)
            
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

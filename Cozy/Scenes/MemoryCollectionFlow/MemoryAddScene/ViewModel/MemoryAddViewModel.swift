//
//  MemoryAddViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/30/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift


class MemoryAddViewModel: MemoryAddViewModelType {
    
    // MARK: Outputs & Inputs
    var outputs: MemoryAddViewModelOutput { self }
    var inputs: MemoryAddViewModelInput { self }
    
    // MARK: Outputs
    lazy var items: Driver<[MemoryAddCollectionSection]> = {
        .of(.init(arrayLiteral: MemoryAddCollectionSection.init(title: "Date", items: [.dateItem])))
    }()
    
    // MARK: Inputs
    var confirmButtonTap: PublishRelay<Void> = PublishRelay<Void>()
    var closeButtonTap: PublishRelay<Void> = PublishRelay<Void>()
    
    var selectedDate = BehaviorRelay<Date>(value: Date())
    
    // MARK: Private
    private let disposeBag = DisposeBag()
    private let factory: MemoryFactoryType
    
    // MARK: Init
    init(factory: MemoryFactoryType) {
        self.factory = factory
        
        confirmButtonTap
            .subscribe(onNext: { (_) in
                self.factory.createByDate(self.selectedDate.value)
            })
            .disposed(by: disposeBag)
    }
}

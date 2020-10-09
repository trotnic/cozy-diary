//
//  MemoryAddViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/30/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxCocoa

protocol MemoryAddViewModelOutput {
    var items: Driver<[MemoryAddCollectionSection]> { get }
}

protocol MemoryAddViewModelInput {
    var confirmButtonTap: PublishRelay<Void> { get }
    var closeButtonTap: PublishRelay<Void> { get }
    
    var selectedDate: BehaviorRelay<Date> { get }
}

protocol MemoryAddViewModelType: MemoryAddViewModelOutput, MemoryAddViewModelInput {
    
    // MARK: Outputs & inputs
    var outputs: MemoryAddViewModelOutput { get }
    var inputs: MemoryAddViewModelInput { get }
}

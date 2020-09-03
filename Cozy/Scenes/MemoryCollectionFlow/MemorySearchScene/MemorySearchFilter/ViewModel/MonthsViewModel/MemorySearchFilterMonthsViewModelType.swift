//
//  MemorySearchFilterMonthsViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/3/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift


protocol MemorySearchFilterMonthsViewModelOutput {
    var items: Observable<[BehaviorRelay<MonthModel>]> { get }
    
    var appendItem: Observable<MonthModel> { get }
    var removeItem: Observable<MonthModel> { get }
}

protocol MemorySearchFilterMonthsViewModelInput {
}

protocol MemorySearchFilterMonthsViewModelType {
    var outputs: MemorySearchFilterMonthsViewModelOutput { get }
    var inputs: MemorySearchFilterMonthsViewModelInput { get }
}

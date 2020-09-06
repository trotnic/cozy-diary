//
//  MemorySearchFilterViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol MemorySearchFilterViewModelOutput {
    var items: Observable<[MemorySearchFilterCollectionSection]> { get }
}

protocol MemorySearchFilterViewModelInput {
    var cancelButtonTap: PublishRelay<Void> { get }
    var clearButtonTap: PublishRelay<Void> { get }
}

protocol MemorySearchFilterViewModelType {
    var outputs: MemorySearchFilterViewModelOutput { get }
    var inputs: MemorySearchFilterViewModelInput { get }
}

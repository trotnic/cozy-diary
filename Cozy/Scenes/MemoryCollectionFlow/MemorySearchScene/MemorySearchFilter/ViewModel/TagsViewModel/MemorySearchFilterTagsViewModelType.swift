//
//  MemorySearchFilterTagsViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/2/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift


protocol MemorySearchFilterTagsViewModelOutput {
    var items: Observable<[BehaviorRelay<TagModel>]> { get }
    
    var appendItem: Observable<TagModel> { get }
    var removeItem: Observable<TagModel> { get }
}

protocol MemorySearchFilterTagsViewModelInput {
}

protocol MemorySearchFilterTagsViewModelType {
    var outputs: MemorySearchFilterTagsViewModelOutput { get }
    var inputs: MemorySearchFilterTagsViewModelInput { get }
}

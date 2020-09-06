//
//  TagsListViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift


protocol TagsListViewModelOutput {
    var items: Observable<[String]> { get }
}

protocol TagsListViewModelInput {
    var tagInsert: PublishRelay<String> { get }
    var tagRemove: PublishRelay<String> { get }
    var dismiss: PublishRelay<Void> { get }
}

protocol TagsListViewModelType {
    var outputs: TagsListViewModelOutput { get }
    var inputs: TagsListViewModelInput { get }
}


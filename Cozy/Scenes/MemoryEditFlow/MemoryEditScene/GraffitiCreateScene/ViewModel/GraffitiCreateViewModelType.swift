//
//  GraffitiCreateViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol GraffitiCreateViewModelOutput {
    var saveRequestObservable: Observable<Data> { get }
    var closeRequestObservable: Observable<Void> { get }
}

protocol GraffitiCreateViewModelInput {
    var saveButtonTap: PublishRelay<Data> { get }
    var closeButtonTap: PublishRelay<Void> { get }
}

protocol GraffitiCreateViewModelType {
    var outputs: GraffitiCreateViewModelOutput { get }
    var inputs: GraffitiCreateViewModelInput { get }
}

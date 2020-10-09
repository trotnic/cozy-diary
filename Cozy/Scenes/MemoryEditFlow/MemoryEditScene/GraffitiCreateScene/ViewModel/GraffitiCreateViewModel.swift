//
//  GraffitiCreateViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/24/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa



class GraffitiCreateViewModel: GraffitiCreateViewModelType, GraffitiCreateViewModelOutput, GraffitiCreateViewModelInput {
    
    // MARK: Outputs & Inputs
    var outputs: GraffitiCreateViewModelOutput { self }
    var inputs: GraffitiCreateViewModelInput { self }
    
    // MARK: Outputs
    var saveRequestObservable: Observable<Data> { saveButtonTap.asObservable() }
    var closeRequestObservable: Observable<Void> { closeButtonTap.asObservable() }
    
    // MARK: Inputs
    let closeButtonTap = PublishRelay<Void>()
    let saveButtonTap = PublishRelay<Data>()
    
    // MARK: Private
    
    // MARK: Init
    init() { }
    
}

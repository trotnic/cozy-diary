//
//  GraffitiCreateViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/24/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift


protocol GraffitiCreateViewModelOutput {
    var saveRequestObservable: Observable<Data> { get }
    var closeRequestObservable: Observable<Void> { get }
}

protocol GraffitiCreateViewModelInput {
    var saveRequest: (Data) -> () { get }
    var closeRequest: () -> () { get }
}

protocol GraffitiCreateViewModelType {
    var outputs: GraffitiCreateViewModelOutput { get }
    var inputs: GraffitiCreateViewModelInput { get }
}

class GraffitiCreateViewModel: GraffitiCreateViewModelType, GraffitiCreateViewModelOutput, GraffitiCreateViewModelInput {
    
    var outputs: GraffitiCreateViewModelOutput { return self }
    var inputs: GraffitiCreateViewModelInput { return self }
    
    // MARK: Outputs
    var saveRequestObservable: Observable<Data>
    var closeRequestObservable: Observable<Void>
    
    // MARK: Inputs
    lazy var saveRequest: (Data) -> () = {
        { data in
            self.savePublisher.onNext(data)
        }
    }()
    lazy var closeRequest = { { self.closePublisher.onNext(()) } }()
    
    // MARK: Private
    let savePublisher = PublishSubject<Data>()
    let closePublisher = PublishSubject<Void>()
    
    init() {
        saveRequestObservable = savePublisher.asObservable()
        closeRequestObservable = closePublisher.asObservable()
    }
    
    
}

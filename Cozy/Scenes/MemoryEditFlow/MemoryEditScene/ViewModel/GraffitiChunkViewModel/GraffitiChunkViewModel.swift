//
//  GraffitiChunkViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/4/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class GraffitiChunkViewModel: GraffitiChunkViewModelType, GraffitiChunkViewModelOutput, GraffitiChunkViewModelInput {
    
    // MARK: Outputs & Inputs
    var outputs: GraffitiChunkViewModelOutput { return self }
    var inputs: GraffitiChunkViewModelInput { return self }
    
    // MARK: Outputs
    var graffiti: Observable<Data> {
        graffitiObserver.flatMap { chunk -> Observable<Data> in
            .just(chunk.graffiti)
        }
    }
    
    var shareItem: Observable<Void> { shareButtonTap.asObservable() }
    var copyItem: Observable<Void> { copyButtonTap.asObservable() }
    var removeItem: Observable<Void> { removeButtonTap.asObservable() }
    
    // MARK: Inputs
    let shareButtonTap = PublishRelay<Void>()
    let copyButtonTap = PublishRelay<Void>()
    let removeButtonTap = PublishRelay<Void>()
    
    // MARK: Private
    private let disposeBag = DisposeBag()
    private let graffitiObserver: BehaviorRelay<GraffitiChunk>
    
    // MARK: Init
    init(_ chunk: GraffitiChunk) {
        self.graffitiObserver = .init(value: chunk)
    }
}

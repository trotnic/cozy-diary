//
//  GraffitiChunkViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/4/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol GraffitiChunkViewModelOutput {
    var graffiti: Observable<Data> { get }
    
    var shareItem: Observable<Void> { get }
    var copyItem: Observable<Void> { get }
    var removeItem: Observable<Void> { get }
}

protocol GraffitiChunkViewModelInput {
    var shareButtonTap: PublishRelay<Void> { get }
    var copyButtonTap: PublishRelay<Void> { get }
    var removeButtonTap: PublishRelay<Void> { get }
}

protocol GraffitiChunkViewModelType {
    var outputs: GraffitiChunkViewModelOutput { get }
    var inputs: GraffitiChunkViewModelInput { get }
}

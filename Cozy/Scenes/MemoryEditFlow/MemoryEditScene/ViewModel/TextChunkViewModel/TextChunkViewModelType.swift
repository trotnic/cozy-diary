//
//  TextChunkViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/4/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol TextChunkViewModelOutput {
    var text: BehaviorRelay<NSAttributedString> { get }
    
    var removeTextRequest: Observable<Void> { get }
}

protocol TextChunkViewModelInput {
    var contextRemoveTap: PublishRelay<Void> { get }
}

protocol TextChunkViewModelType {
    var outputs: TextChunkViewModelOutput { get }
    var inputs: TextChunkViewModelInput { get }
}

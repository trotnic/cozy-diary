//
//  TextChunkViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/4/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class TextChunkViewModel: TextChunkViewModelType, TextChunkViewModelOutput, TextChunkViewModelInput {
    
    var outputs: TextChunkViewModelOutput { return self }
    var inputs: TextChunkViewModelInput { return self }
    
    // MARK: Outputs
    var text: BehaviorRelay<NSAttributedString>
    
    var removeTextRequest: Observable<Void> { contextRemoveTap.asObservable() }
    
    // MARK: Inputs
    let contextRemoveTap = PublishRelay<Void>()
    
    // MARK: Private
    private let chunk: TextChunk
    private let disposeBag = DisposeBag()
    
    // MARK: Init
    init(_ chunk: TextChunk) {
        self.chunk = chunk
        text = .init(value: chunk.text)
        
        text.bind { [weak self] text in
            self?.chunk.text = text
        }.disposed(by: disposeBag)
    }
}

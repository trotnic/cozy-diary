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
    
    var removeTextRequest: Observable<Void>
    
    // MARK: Inputs
    lazy var tapRequest = { {} }()
    lazy var longPressRequest = { {} }()
    lazy var contextRemoveRequest = { { self.removeRequestPublisher.onNext(()) } }()
    
    // MARK: Private
    private let chunk: TextChunk
    private let disposeBag = DisposeBag()
    
    private let removeRequestPublisher = PublishSubject<Void>()
    
    // MARK: Init
    init(_ chunk: TextChunk) {
        self.chunk = chunk
        text = .init(value: chunk.text)
        
        removeTextRequest = removeRequestPublisher.asObservable()
        
        text.bind { [weak self] text in
            self?.chunk.text = text
        }.disposed(by: disposeBag)
    }
}

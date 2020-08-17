//
//  MemoryCreateViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class MemoryCreateViewModel: MemoryCreateViewModelProtocol {
    var viewDidLoad = PublishRelay<Void>()
    var viewDidAddTextChunk = PublishRelay<Void>()
    
    private let cdModeller: CoreDataModeller
    var currentMemory: BehaviorSubject<Memory>
    
    var chunks: Array<TextChunkViewModel> = []
    
    private let disposeBag = DisposeBag()
    
    init(memory: BehaviorSubject<Memory>) {
        
        currentMemory = memory
        cdModeller = CoreDataModeller(manager: CoreDataManager())
        
        currentMemory.subscribe(onNext: { [weak self] (memory) in
            self?.chunks = memory.texts.map { text -> TextChunkViewModel in
                .init(text)
            }
        })
        .disposed(by: disposeBag)
    }
    
    
    func setupCurrentMemory() {
     
        
        
    }
    
    
}


class TextChunkViewModel {
    
    var text: BehaviorRelay<String>
    var index: BehaviorRelay<Int>
    
    private let chunk: TextChunk
    private let disposeBag = DisposeBag()
    
    
    init(_ chunk: TextChunk) {
        self.chunk = chunk
        text = .init(value: chunk.text)
        index = .init(value: chunk.index)
        
        text.bind { [weak self] text in
            self?.chunk.text = text
        }.disposed(by: disposeBag)
        
        
    }
    
}

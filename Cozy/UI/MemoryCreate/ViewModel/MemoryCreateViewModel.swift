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
import RxDataSources


class MemoryCreateViewModel: MemoryCreateViewModelProtocol {
    
    typealias DataSource = RxCollectionViewSectionedReloadDataSource<MemoryCreateCollectionSection>
    
    var dataSource: DataSource
    
    var viewDidLoad = PublishRelay<Void>()
    var viewDidAddTextChunk = PublishRelay<Void>()
    
    var currentMemory: BehaviorRelay<Memory>
    
    var items: BehaviorRelay<[MemoryCreateCollectionSection]>!
    
    private let disposeBag = DisposeBag()
    
    init(memory: BehaviorRelay<Memory>) {
        dataSource = MemoryCreateDataSource.dataSource()
        currentMemory = memory
        items = .init(value: [])
        
        viewDidAddTextChunk.subscribe(onNext: { [weak self] in
            if let value = self?.currentMemory.value {
                value.insertTextChunk("")
                self?.currentMemory.accept(value)
            }
        }).disposed(by: disposeBag)
        
        currentMemory.subscribe(onNext: { [weak self] memory in
            self?.items.accept([
                .init(items: memory.sortedChunks.map { chunk -> MemoryCreateCollectionItem in
                    .TextItem(viewModel: TextChunkViewModel(chunk as! TextChunk))
                })
            ])
        }).disposed(by: disposeBag)
        
        
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

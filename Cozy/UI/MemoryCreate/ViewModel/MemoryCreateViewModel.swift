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
    var viewDidAddPhotoChunk = PublishRelay<Data>()
    
    var currentMemory: BehaviorRelay<Memory>
    
    var items: BehaviorRelay<[MemoryCreateCollectionSection]>!
    
    private let disposeBag = DisposeBag()
    
    init(memory: BehaviorRelay<Memory>) {
        dataSource = MemoryCreateDataSource.dataSource()
        currentMemory = memory
        items = .init(value: [])
        
        
        currentMemory.subscribe(onNext: { [weak self] memory in
            self?.items.accept([
                .init(items: memory.sortedChunks.map { chunk -> MemoryCreateCollectionItem in
                    if let textChunk = chunk as? TextChunk {
                        return .TextItem(viewModel: .init(textChunk))
                    } else {
                        return .PhotoItem(viewModel: .init(chunk as! PhotoChunk))
                    }
                })
            ])
        }).disposed(by: disposeBag)
        
        bindView()
    }
    
    private func bindView() {
        viewDidAddTextChunk.subscribe(onNext: { [weak self] in
            if let value = self?.currentMemory.value {
                if ((value.sortedChunks.last as? TextChunkable) == nil) {
                    value.insertTextChunk("")
                    self?.currentMemory.accept(value)
                }

            }
        }).disposed(by: disposeBag)
        
        viewDidAddPhotoChunk.subscribe(onNext: { [weak self] image in
            if let value = self?.currentMemory.value {
                value.insertPhoto(image)
                self?.currentMemory.accept(value)
            }
        }).disposed(by: disposeBag)
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

class PhotoChunkViewModel {
    var photo: BehaviorRelay<Data>
    var index: BehaviorRelay<Int>
    
    private let chunk: PhotoChunk
    private let disposeBag = DisposeBag()
    
    init(_ chunk: PhotoChunk) {
        self.chunk = chunk
        photo = .init(value: chunk.photo)
        index = .init(value: chunk.index)
        
        photo.bind { [weak self] photo in
            self?.chunk.photo = photo
        }.disposed(by: disposeBag)
    }
}

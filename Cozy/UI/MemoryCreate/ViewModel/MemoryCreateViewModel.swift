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
    
//    typealias DataSource = RxCollectionViewSectionedReloadDataSource<MemoryCreateCollectionSection>
    
//    var dataSource: DataSource
    
    var viewDidLoad = PublishRelay<Void>()
    var textChunkRequest = PublishRelay<Void>()
    var photoChunkRequest = PublishRelay<Data>()
    
    var textChunkGrows = PublishRelay<Void>()
    
    var currentMemory: BehaviorRelay<Memory>
    
    var items: BehaviorRelay<[MemoryCreateCollectionItem]>!
    
    private let disposeBag = DisposeBag()
    
    init(memory: BehaviorRelay<Memory>) {
        currentMemory = memory
        items = .init(value: [])

        currentMemory.subscribe(onNext: { [weak self] memory in
            self?.items.accept(
                memory.sortedChunks.map { chunk -> MemoryCreateCollectionItem in
                    if let textChunk = chunk as? TextChunk {
                        let viewModel = TextChunkViewModel(textChunk)
//                        viewModel.cellGrows.subscribe(onNext: { [weak self] in
//                            self?.textChunkGrows.accept(())
//                        }).disposed(by: self!.disposeBag)
                        return .TextItem(viewModel: viewModel)
                    } else {
                        let viewModel = PhotoChunkViewModel(chunk as! PhotoChunk)
                        
                        viewModel.tapRequest.subscribe(onNext: {
                            print("TAP")
                        }).disposed(by: self!.disposeBag)
                        
                        viewModel.longPressRequest.subscribe(onNext: {
                            print("LONG")
                        }).disposed(by: self!.disposeBag)
                        
                        return .PhotoItem(viewModel: viewModel)
                    }
                }
            )
        }).disposed(by: disposeBag)
        
        bindView()
    }
    
    private func bindView() {
        textChunkRequest.subscribe(onNext: { [weak self] in
            if let value = self?.currentMemory.value {
                if ((value.sortedChunks.last as? TextChunkable) == nil) {
                    value.insertTextChunk("")
                    self?.currentMemory.accept(value)
                }

            }
        }).disposed(by: disposeBag)
        
        photoChunkRequest.subscribe(onNext: { [weak self] image in
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
    
    var cellGrows = PublishRelay<Void>()
    
    var cellReceiveTap = PublishRelay<Void>()
    
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
    
    var tapRequest = PublishRelay<Void>()
    var longPressRequest = PublishRelay<Void>()
    
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

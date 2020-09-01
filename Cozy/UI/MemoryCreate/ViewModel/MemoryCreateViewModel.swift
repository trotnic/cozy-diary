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


class MemoryCreateViewModel: MemoryCreateViewModelType, MemoryCreateViewModelOutput, MemoryCreateViewModelInput {
    var title: Driver<String> {
        Observable.just("").asDriver(onErrorJustReturn: "")
    }
    
    
    var outputs: MemoryCreateViewModelOutput { return self }
    var inputs: MemoryCreateViewModelInput { return self }
    
    // MARK: Outputs
    var items: BehaviorRelay<[MemoryCreateCollectionItem]> = .init(value: [])
    var photoInsertRequestObservable: Observable<Void>
    var photoDetailRequestObservable: Observable<Data>
    var photoShareRequestObservable: Observable<Data>
    
    var mapInsertRequestObservable: Observable<Void>
    
    var graffitiInsertRequestObservable: Observable<Void>
    
    // MARK: Inputs
    
    lazy var saveRequest: () -> ()  = { {
        self.memoryStore.updateItem(self.currentMemory.value)
        self.memoryStore.leaveAway(key: self.currentMemory.value.date)
    } }()
    
    lazy var textChunkInsertRequest = { {
        let value = self.currentMemory.value
        if(value.sortedChunks.last as? TextChunkable) == nil {
            value.insertTextChunk("")
            self.currentMemory.accept(value)
        }
    } }()
    
    lazy var photoChunkInsertRequest = { { self.photoInsertRequestPublisher.onNext(()) } }()
    
    lazy var photoInsertResponse: (ImageMeta) -> () = {
        { meta in
            if let image = meta.originalImage {
                let value = self.currentMemory.value
                value.insertPhoto(image)
                self.currentMemory.accept(value)
            }
        }
    }()
    
    lazy var graffitiInsertResponse: (Data) -> () = {
        { graffiti in
            let value = self.currentMemory.value
            value.insertGraffiti(graffiti)
            self.currentMemory.accept(value)
        }
    }()
    
    lazy var mapChunkInsertRequest = { { self.mapChunkRequestPublisher.onNext(()) } }()
    
    lazy var graffitiChunkInsertRequest = { { self.graffitiChunkRequestPublisher.onNext(()) } }()
    
    // MARK: Private
    private let photoInsertRequestPublisher = PublishSubject<Void>()
    private let photoDetailRequestPublisher = PublishSubject<Data>()
    private let photoShareRequestPublisher = PublishSubject<Data>()
    
    private let mapChunkRequestPublisher = PublishSubject<Void>()
    private let graffitiChunkRequestPublisher = PublishSubject<Void>()
    
    private var currentMemory: BehaviorRelay<Memory>
    private let disposeBag = DisposeBag()
    
    private let memoryStore: MemoryStoreType

    // MARK: Init
    init(memory: BehaviorRelay<Memory>, memoryStore: MemoryStoreType) {
        currentMemory = memory
        self.memoryStore = memoryStore
        
        photoInsertRequestObservable = photoInsertRequestPublisher.asObservable()
        photoDetailRequestObservable = photoDetailRequestPublisher.asObservable()
        photoShareRequestObservable = photoShareRequestPublisher.asObservable()
        
        mapInsertRequestObservable = mapChunkRequestPublisher.asObservable()
        
        graffitiInsertRequestObservable = graffitiChunkRequestPublisher.asObservable()
        
        bindRelevantMemory()
        
        memoryStore.seekFor(currentMemory, key: currentMemory.value.date)
    }
    
    private func bindRelevantMemory() {
        
        currentMemory.subscribe(onNext: { [unowned self] memory in
            self.items.accept(
                memory.sortedChunks.map { chunk -> MemoryCreateCollectionItem in

                    if let textChunk = chunk as? TextChunk {
                        let viewModel = TextChunkViewModel(textChunk)
                        
                        viewModel.outputs.removeTextRequest.subscribe(onNext: { [weak self] in
                            
                            if let value = self?.currentMemory.value {
                                value.removeChunk(textChunk)
                                self?.currentMemory.accept(value)
                            }
                        }).disposed(by: self.disposeBag)
                        
                        return .TextItem(viewModel: viewModel)
                    } else if let graffitiChunk = chunk as? GraffitiChunk {
                        let viewModel = GraffitiChunkViewModel(graffitiChunk)
                        return .GraffitiItem(viewModel: viewModel)
                    } else {
                        let photoChunk = chunk as! PhotoChunk
                        let viewModel = PhotoChunkViewModel(photoChunk)
                        
                        viewModel.outputs
                            .detailPhotoRequestObservable
                            .subscribe(onNext: { [weak self] in
                                
                                self?.photoDetailRequestPublisher
                                    .onNext(photoChunk.photo)
                        }).disposed(by: self.disposeBag)
                        
                        viewModel.outputs
                            .copyPhotoRequest
                            .subscribe(onNext: { (_) in
                                
                                DispatchQueue.global(qos: .utility).async {
                                    UIPasteboard.general.image = UIImage(data: photoChunk.photo)
                                }
                        }).disposed(by: self.disposeBag)
                        
                        viewModel.outputs
                            .sharePhotoRequest
                            .subscribe(onNext: { [weak self] in
                                
                                self?.photoShareRequestPublisher
                                    .onNext(photoChunk.photo)
                        }).disposed(by: self.disposeBag)
                        
                        viewModel.outputs
                            .removePhotoRequest
                            .subscribe(onNext: { [weak self] in
                                
                                if let value = self?.currentMemory.value {
                                    value.removeChunk(photoChunk)
                                    self?.currentMemory.accept(value)
                                }
                        }).disposed(by: self.disposeBag)
                        
                        return .PhotoItem(viewModel: viewModel)
                    }
                }
            )
        }).disposed(by: disposeBag)
    }
    
    deinit {
        memoryStore.updateItem(currentMemory.value)
    }
}


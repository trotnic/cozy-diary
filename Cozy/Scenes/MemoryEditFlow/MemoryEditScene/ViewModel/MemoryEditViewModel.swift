//
//  MemoryEditViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/28/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa




class MemoryEditViewModel: MemoryCreateViewModelType, MemoryCreateViewModelOutput, MemoryCreateViewModelInput {
    
    
    // MARK: Outputs & Inputs
    var outputs: MemoryCreateViewModelOutput { return self }
    var inputs: MemoryCreateViewModelInput { return self }
    
    
    // MARK: Outputs
    let items = BehaviorRelay<[MemoryCreateCollectionItem]>(value: [])
    
    var photoInsertRequestObservable: Observable<Void> { photoInsertObserver.asObservable() }
    var photoDetailRequestObservable: Observable<Data> { photoDetailObserver.asObservable() }
    var photoShareRequestObservable: Observable<Data> { photoShareObserver.asObservable() }
    
    var mapInsertRequestObservable: Observable<Void> { mapInsertObserver.asObservable() }
    
    var graffitiInsertRequestObservable: Observable<Void> { graffitiInsertObserver.asObservable() }
    
    
    // MARK: Inputs
    lazy var saveRequest: () -> () = { {} }()
    
    lazy var textChunkInsertRequest: () -> () = {
        {
            let value = self.memory.value
            if (value.sortedChunks.last as? TextChunkable) == nil {
                value.insertTextChunk("")
                self.memory.accept(value)
            }
        }
    }()
    
    lazy var photoChunkInsertRequest: () -> () = {
        {
            self.photoInsertObserver.onNext(())
        }
    }()
    
    lazy var mapChunkInsertRequest: () -> () = {
        {
            self.mapInsertObserver.onNext(())
        }
    }()
    
    lazy var graffitiChunkInsertRequest: () -> () = {
        {
            self.graffitiInsertObserver.onNext(())
        }
    }()
    
    lazy var photoInsertResponse: (ImageMeta) -> () = {
        { meta in
            if let image = meta.originalImage {
                let value = self.memory.value
                value.insertPhoto(image)
                self.memory.accept(value)
            }
        }
    }()
    
    lazy var graffitiInsertResponse: (Data) -> () = {
        { graffiti in
            let value = self.memory.value
            value.insertGraffiti(graffiti)
            self.memory.accept(value)
        }
    }()
    
    
    // MARK: Private
    private let photoInsertObserver = PublishSubject<Void>()
    private let photoDetailObserver = PublishSubject<Data>()
    private let photoShareObserver = PublishSubject<Data>()
    private let mapInsertObserver = PublishSubject<Void>()
    private let graffitiInsertObserver = PublishSubject<Void>()
    
    private let memory: BehaviorRelay<Memory>
    private let memoryStore: MemoryStoreType
    
    private let disposeBag = DisposeBag()
    
    
    // MARK: Init
    init(memory: BehaviorRelay<Memory>, memoryStore: MemoryStoreType) {
        self.memory = memory
        self.memoryStore = memoryStore
        
        bindMemory()
        
        memoryStore.seekFor(memory, key: memory.value.date)
    }
    
    
    // MARK: Private methods
    private func bindMemory() {
        memory.subscribe(onNext: { [unowned self] memory in
            self.items.accept(
                memory.sortedChunks.map { chunk -> MemoryCreateCollectionItem in

                    if let textChunk = chunk as? TextChunk {
                        let viewModel = TextChunkViewModel(textChunk)
                        
                        viewModel.outputs.removeTextRequest.subscribe(onNext: { [weak self] in

                            if let value = self?.memory.value {
                                value.removeChunk(textChunk)
                                self?.memory.accept(value)
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

                                self?.photoDetailObserver
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

                                self?.photoShareObserver
                                    .onNext(photoChunk.photo)
                        }).disposed(by: self.disposeBag)
                        
                        viewModel.outputs
                            .removePhotoRequest
                            .subscribe(onNext: { [weak self] in

                                if let value = self?.memory.value {
                                    value.removeChunk(photoChunk)
                                    self?.memory.accept(value)
                                }
                        }).disposed(by: self.disposeBag)
                        
                        return .PhotoItem(viewModel: viewModel)
                    }
                }
            )
        }).disposed(by: disposeBag)
    }
    
    
    
    
}

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
    
    lazy var title: Driver<String> = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let result = dateFormatter.string(from: memory.value.date)
        return Observable.just(result).asDriver(onErrorJustReturn: "")
    }()
    
    var photoInsertRequestObservable: Observable<Void> { photoChunkAdd.asObservable() }
    var photoDetailRequestObservable: Observable<Data> { photoDetailObserver.asObservable() }
    var photoShareRequestObservable: Observable<Data> { photoShareObserver.asObservable() }
    
    var tagAddRequestObservable: Observable<Memory> {
        tagAdd.flatMap({ [unowned self] (_) -> Observable<Memory> in
            .just(self.memory.value)
        })
    }
    
    var graffitiInsertRequestObservable: Observable<Void> { graffitiChunkAdd.asObservable() }
    
    var voiceInsertRequestObservable: Observable<VoiceChunkManagerType> {
        voiceChunkAdd
            .flatMap { [unowned self] _ -> Observable<VoiceChunkManagerType> in
                let manager = VoiceChunkManager()
                
                manager.voiceFileUrl
                    .subscribe(onNext: { (fileUrl) in
                        let value = self.memory.value
                        value.insertVoice(fileUrl)
                        self.memory.accept(value)
                    })
                .disposed(by: self.disposeBag)
                
                return .just(manager)
            }
    }
    
    var shouldClearStack: Observable<Void> { shouldClearStackObserver.asObservable() }
    
    var shouldDeleteMemory: Observable<Void> { shouldDeleteMemoryObserver.asObservable() }
    
    // MARK: Inputs
    let viewWillAppear = PublishRelay<Void>()
    let viewWillDisappear = PublishRelay<Void>()
    
    let textChunkAdd = PublishRelay<Void>()
    let photoChunkAdd = PublishRelay<Void>()
    let graffitiChunkAdd = PublishRelay<Void>()
    let tagAdd = PublishRelay<Void>()
    let voiceChunkAdd = PublishRelay<Void>()
    
    let deleteMemoryButtonTap = PublishRelay<Void>()
    
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
    
    let provideMemory = PublishRelay<BehaviorRelay<Memory>>()
    
    // MARK: Private
    private let photoInsertObserver = PublishSubject<Void>()
    private let photoDetailObserver = PublishSubject<Data>()
    private let photoShareObserver = PublishSubject<Data>()
    private let tagAddObserver = PublishSubject<Memory>()
    private let graffitiInsertObserver = PublishSubject<Void>()
    
    private let shouldClearStackObserver = PublishRelay<Void>()
    private let shouldDeleteMemoryObserver = PublishRelay<Void>()
    
    private var memory: BehaviorRelay<Memory>
    private let memoryStore: MemoryStoreType
    
    private let disposeBag = DisposeBag()
    
    // MARK: Init
    init(memory: BehaviorRelay<Memory>, memoryStore: MemoryStoreType) {
        self.memory = memory
        self.memoryStore = memoryStore
        
        bindMemory()
        setupTextChunkAdd()
        
        viewWillAppear
            .subscribe(onNext: { [weak self] (_) in
                self?.memoryStore.seekFor(memory, key: memory.value.date)
                self?.shouldClearStackObserver.accept(())
        }).disposed(by: disposeBag)
        
        viewWillDisappear
            .map { [unowned self] _ -> Date in
                self.memory.value.date
            }
            .subscribe(onNext: { [weak self] (date) in
                self?.memoryStore.leaveAway(key: date)
        }).disposed(by: disposeBag)
        
        deleteMemoryButtonTap
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.memoryStore.removeItem(self.memory.value)
                self.shouldDeleteMemoryObserver.accept(())
        }).disposed(by: disposeBag)

        // TODO: Bad, should think about segregation
        provideMemory
            .subscribe(onNext: { [weak self] (memory) in
                self?.memory = memory
                self?.bindMemory()
                self?.memoryStore.seekFor(memory, key: memory.value.date)
        }).disposed(by: disposeBag)
    }
    
    // MARK: Private methods
    private func bindMemory() {
        memory.subscribe(onNext: { [unowned self] memory in
            self.items.accept(
                memory.sortedChunks.map { chunk -> MemoryCreateCollectionItem in
                    if let textChunk = chunk as? TextChunk {
                        return self.textChunkItem(textChunk)
                    } else if let graffitiChunk = chunk as? GraffitiChunk {
                        return self.graffitiCHunkItem(graffitiChunk)
                    } else if let photoChunk = chunk as? PhotoChunk {
                        return self.photoChunkItem(photoChunk)
                    } else {
                        let voiceChunk = chunk as! VoiceChunk
                        return self.voiceChunkItem(voiceChunk)
                    }
                }
            )
        }).disposed(by: disposeBag)
    }
    
    private func setupTextChunkAdd() {
        textChunkAdd.subscribe(onNext: { [weak self] (_) in
            guard let self = self else { return }
            let value = self.memory.value
            if (value.sortedChunks.last as? TextChunkable) == nil {
                value.insertTextChunk("")
                self.memory.accept(value)
            }
        })
        .disposed(by: disposeBag)
    }

    private func textChunkItem(_ textChunk: TextChunk) -> MemoryCreateCollectionItem {
        let viewModel = TextChunkViewModel(textChunk)
        viewModel.outputs.removeTextRequest
            .subscribe(onNext: { [weak self] in
                if let value = self?.memory.value {
                    value.removeChunk(textChunk)
                    self?.memory.accept(value)
                }
        }).disposed(by: self.disposeBag)
        return .TextItem(viewModel: viewModel)
    }
    
    private func graffitiCHunkItem(_ graffitiChunk: GraffitiChunk) -> MemoryCreateCollectionItem {
        let viewModel = GraffitiChunkViewModel(graffitiChunk)
        
        viewModel.outputs
            .copyItem
            .subscribe(onNext: { (_) in
                DispatchQueue.global(qos: .utility).async {
                    UIPasteboard.general.image = UIImage(data: graffitiChunk.graffiti)
                }
            }).disposed(by: disposeBag)
        
        viewModel.outputs
            .shareItem
            .subscribe(onNext: { [weak self] in
                self?.photoShareObserver.onNext(graffitiChunk.graffiti)
            }).disposed(by: disposeBag)
        
        viewModel.outputs
            .removeItem
            .subscribe(onNext: { [weak self] (_) in
                if let value = self?.memory.value {
                    value.removeChunk(graffitiChunk)
                    self?.memory.accept(value)
                }
            }).disposed(by: disposeBag)
        
        return .GraffitiItem(viewModel: viewModel)
    }
    
    private func photoChunkItem(_ photoChunk: PhotoChunk) -> MemoryCreateCollectionItem {
        let viewModel = PhotoChunkViewModel(photoChunk)
        
        viewModel.outputs
            .detailPhotoRequestObservable
            .subscribe(onNext: { [weak self] in
                self?.photoDetailObserver.onNext(photoChunk.photo)
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
    
    private func voiceChunkItem(_ voiceChunk: VoiceChunk) -> MemoryCreateCollectionItem {
        let viewModel = VoiceChunkViewModel(voiceChunk)
        
        viewModel.outputs
            .removeItemRequest
            .subscribe(onNext: { [weak self] in
                if let value = self?.memory.value {
                    value.removeChunk(voiceChunk)
                    self?.memory.accept(value)
                }
            })
        .disposed(by: disposeBag)
        
        return .VoiceItem(viewModel: viewModel)
    }
}

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


enum MemoryCreateCollectionItem {
    case TextItem(viewModel: TextChunkViewModelType)
    case PhotoItem(viewModel: PhotoChunkViewModelType)
    case GraffitiItem(viewModel: GraffitiChunkViewModelType)
}

protocol MemoryCreateViewModelOutput {
    var items: BehaviorRelay<[MemoryCreateCollectionItem]> { get }
    
    var photoInsertRequestObservable: Observable<Void> { get }
    var photoDetailRequestObservable: Observable<Data> { get }
    var photoShareRequestObservable: Observable<Data> { get }
    
    var mapInsertRequestObservable: Observable<Void> { get }
    
    var graffitiInsertRequestObservable: Observable<Void> { get }
}

protocol MemoryCreateViewModelInput {
    var viewDidLoad: () -> () { get }
    
    var textChunkInsertRequest: () -> () { get }
    var photoChunkInsertRequest: () -> () { get }
    var mapChunkInsertRequest: () -> () { get }
    var graffitiChunkInsertRequest: () -> () { get }
    
    var photoInsertResponse: (ImageMeta) -> () { get }
    var graffitiInsertResponse: (Data) -> () { get }
}

protocol MemoryCreateViewModelType {
    var outputs: MemoryCreateViewModelOutput { get }
    var inputs: MemoryCreateViewModelInput { get }
}

class MemoryCreateViewModel: MemoryCreateViewModelType, MemoryCreateViewModelOutput, MemoryCreateViewModelInput {
    
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
    lazy var viewDidLoad = { { } }()
    
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

    // MARK: Init
    init(memory: BehaviorRelay<Memory>) {
        currentMemory = memory
        photoInsertRequestObservable = photoInsertRequestPublisher.asObservable()
        photoDetailRequestObservable = photoDetailRequestPublisher.asObservable()
        photoShareRequestObservable = photoShareRequestPublisher.asObservable()
        
        mapInsertRequestObservable = mapChunkRequestPublisher.asObservable()
        
        graffitiInsertRequestObservable = graffitiChunkRequestPublisher.asObservable()
        
        bindRelevantMemory()
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
}

// MARK: Text Chunk ViewModel

protocol TextChunkViewModelOutput {
    var text: BehaviorRelay<NSAttributedString> { get }
    
    var removeTextRequest: Observable<Void> { get }
}

protocol TextCHunkViewModelInput {
    var tapRequest: () -> () { get }
    var longPressRequest: () -> () { get }
    
    var contextRemoveRequest: () -> () { get }
}

protocol TextChunkViewModelType {
    var outputs: TextChunkViewModelOutput { get }
    var inputs: TextCHunkViewModelInput { get }
}

class TextChunkViewModel: TextChunkViewModelType, TextChunkViewModelOutput, TextCHunkViewModelInput {
    
    var outputs: TextChunkViewModelOutput { return self }
    var inputs: TextCHunkViewModelInput { return self }
    
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

// MARK: Photo Chunk ViewModel

protocol PhotoChunkViewModelOutput {
    var photo: BehaviorRelay<Data> { get }
    
    var detailPhotoRequestObservable: Observable<Void> { get }
    
    var sharePhotoRequest: Observable<Void> { get }
    var copyPhotoRequest: Observable<Void> { get }
    var removePhotoRequest: Observable<Void> { get }
}

protocol PhotoChunkViewModelInput {
    var tapRequest: () -> () { get }
    var longPressRequest: () -> () { get }
    
    var contextShareRequest: () -> () { get }
    var contextCopyRequest: () -> () { get }
    var contextRemoveRequest: () -> () { get }
}

protocol PhotoChunkViewModelType {
    var outputs: PhotoChunkViewModelOutput { get }
    var inputs: PhotoChunkViewModelInput { get }
}

class PhotoChunkViewModel: PhotoChunkViewModelType, PhotoChunkViewModelOutput, PhotoChunkViewModelInput {
    var outputs: PhotoChunkViewModelOutput { return self }
    var inputs: PhotoChunkViewModelInput { return self }
    
    // MARK: Outputs
    var photo: BehaviorRelay<Data>
    
    var detailPhotoRequestObservable: Observable<Void>
    
    var sharePhotoRequest: Observable<Void>
    var copyPhotoRequest: Observable<Void>
    var removePhotoRequest: Observable<Void>
    
    // MARK: Inputs
    lazy var tapRequest = { { self.tapRequestPublisher.onNext(()) } }()
    lazy var longPressRequest = { {} }()
    
    lazy var contextShareRequest = { { self.shareRequestPublisher.onNext(()) } }()
    lazy var contextCopyRequest = { { self.copyRequestPublisher.onNext(()) } }()
    lazy var contextRemoveRequest = { { self.removeRequestPublisher.onNext(()) } }()
    
    // MARK: Private
    private let chunk: PhotoChunk
    private let disposeBag = DisposeBag()
    
    private let tapRequestPublisher = PublishSubject<Void>()
    
    private let shareRequestPublisher = PublishSubject<Void>()
    private let copyRequestPublisher = PublishSubject<Void>()
    private let removeRequestPublisher = PublishSubject<Void>()
    
    // MARK: Init
    init(_ chunk: PhotoChunk) {
        self.chunk = chunk
        photo = .init(value: chunk.photo)
        
        detailPhotoRequestObservable = tapRequestPublisher.asObservable()
        
        sharePhotoRequest = shareRequestPublisher.asObservable()
        copyPhotoRequest = copyRequestPublisher.asObservable()
        removePhotoRequest = removeRequestPublisher.asObservable()
        
        photo.bind { [weak self] photo in
            self?.chunk.photo = photo
        }.disposed(by: disposeBag)
    }
}

// MARK: Graffiti Chunk View Model

protocol GraffitiChunkViewModelOutput {
    var graffiti: Observable<Data> { get }
}

protocol GraffitiChunkViewModelInput {
    
}

protocol GraffitiChunkViewModelType {
    var outputs: GraffitiChunkViewModelOutput { get }
    var inputs: GraffitiChunkViewModelInput { get }
}

class GraffitiChunkViewModel: GraffitiChunkViewModelType, GraffitiChunkViewModelOutput, GraffitiChunkViewModelInput {
    
    var outputs: GraffitiChunkViewModelOutput { return self }
    var inputs: GraffitiChunkViewModelInput { return self }
    
    // MARK: Outputs
    let graffiti: Observable<Data>
    
    // MARK: Inputs
    
    // MARK: Private
    private let chunk: GraffitiChunk
    private let disposeBag = DisposeBag()
    
    // MARK: Init
    init(_ chunk: GraffitiChunk) {
        self.chunk = chunk
        graffiti = .just(chunk.graffiti)
    }
}


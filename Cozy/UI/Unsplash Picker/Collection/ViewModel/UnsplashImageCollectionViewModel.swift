//
//  UnsplashImageCollectionViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/26/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol UnsplashImageCollectionViewModelOutput {
    var isLoadingFirstPage: BehaviorRelay<Bool> { get }
    var isLoadingAdditionalPhotos: BehaviorRelay<Bool> { get }
    var items: BehaviorRelay<[UnsplashPhoto]> { get }
    var imageRetrievedSuccess: PublishRelay<(UIImage, Int)> { get }
    var imageRetrievedError: PublishRelay<Int> { get }
    
//    var detailImageRequest: Signal<UnsplashPhoto> { get }
}

protocol UnsplashImageCollectionViewModelInput {
    var viewDidLoad: PublishRelay<Void> { get }
    var willDisplayCellAtIndex: PublishRelay<Int> { get }
    var didSelectModelWithId: PublishRelay<String> { get }
    var didScrollToTheBottom: PublishRelay<Void> { get }
}

protocol UnsplashImageCollectionViewModelType {
    var outputs: UnsplashImageCollectionViewModelOutput { get }
    var inputs: UnsplashImageCollectionViewModelInput { get }
}

class UnsplashImageCollectionViewModel: UnsplashImageCollectionViewModelType, UnsplashImageCollectionViewModelOutput, UnsplashImageCollectionViewModelInput {
    
    var outputs: UnsplashImageCollectionViewModelOutput { return self }
    var inputs: UnsplashImageCollectionViewModelInput { return self }
    
    // MARK: Outputs
    let isLoadingFirstPage = BehaviorRelay<Bool>(value: false)
    let isLoadingAdditionalPhotos = BehaviorRelay<Bool>(value: false)
    let items = BehaviorRelay<[UnsplashPhoto]>(value: [])
    let imageRetrievedSuccess = PublishRelay<(UIImage, Int)>()
    let imageRetrievedError = PublishRelay<Int>()
    
    // MARK: Inputs
    let viewDidLoad = PublishRelay<Void>()
    let willDisplayCellAtIndex = PublishRelay<Int>()
    let didSelectModelWithId = PublishRelay<String>()
    let didScrollToTheBottom = PublishRelay<Void>()
    
    // MARK: Private
    private let disposeBag = DisposeBag()
    private let pageNumber = BehaviorRelay<Int>(value: 0)
    lazy var pageNumberObs = pageNumber.asObservable()
    
    private let service: UnsplashServiceType
    
    private let cache: PhotoCacheType
    
    private let detailObserver = PublishRelay<UnsplashPhoto>()
    
    // MARK: Init
    init(service: UnsplashServiceType, cache: PhotoCacheType) {
        self.service = service
        self.cache = cache
        
        bindOnViewDidLoad()
        bindOnWillDisplayCell()
        bindOnDidScrollToBottom()
        bindPageNumber()
        
        bindOnDidSelectModel()
    }
    
    // MARK: Private methods
    private func bindOnViewDidLoad() {
        viewDidLoad
            .observeOn(MainScheduler.instance)
            .do(onNext: { [unowned self] _ in
                self.loadData()
            })
        .subscribe()
        .disposed(by: disposeBag)
    }
    
    private func bindOnWillDisplayCell() {
        willDisplayCellAtIndex
            .filter { [unowned self] index in self.items.value.indices.contains(index) }
            .map { [unowned self] index in (index, string: self.items.value[index].urls.thumb) }
            .compactMap { [weak self] (index, urlString) -> (Int, URL)? in
                guard let url = URL(string: urlString) else {
                    DispatchQueue.main.async {
                    self?.imageRetrievedError.accept(index)
                    }
                    return nil
                }
                return (index, url)
            }
            .flatMap { [unowned self] index, url in
                self.cache.fetchPhotoFor(url: url)
                    .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                    .concatMap { (data) in
                        Observable.of((index, data))
                }
            }
            .subscribe(onNext: { [weak self] (index, data) in
                guard let self = self else { return }
//                guard let image = UIImage(data: data) else {
//                    self.imageRetrievedError.accept(index)
//                    return
//                }
                self.imageRetrievedSuccess.accept((data, index))
            })
        .disposed(by: disposeBag)
    }
    
    
    private func bindOnDidScrollToBottom() {
        didScrollToTheBottom
            .flatMap { [unowned self] _ -> Observable<Int> in
                let newPageNumber = self.pageNumber.value + 1
                return .just(newPageNumber)
            }
            .bind(to: pageNumber)
        .disposed(by: disposeBag)
    }
    
    private func bindPageNumber() {
        pageNumber
            .subscribe(onNext: { [weak self] _ in
                self?.loadData()
            })
        .disposed(by: disposeBag)
    }
    
    private func bindOnDidSelectModel() {
        didSelectModelWithId
            .subscribe(onNext: { [unowned self] (id) in
                
            })
        .disposed(by: disposeBag)
    }
    
    private func loadData() {
        if pageNumber.value == 1 {
            isLoadingFirstPage.accept(true)
        } else {
            isLoadingAdditionalPhotos.accept(true)
        }
        
        service.fetch(request: .photos(page: pageNumber.value, limit: 40))
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.pageNumber.value == 1 {
                    self.isLoadingFirstPage.accept(false)
                } else {
                    self.isLoadingAdditionalPhotos
                        .accept(false)
                }
            })
            
            .flatMap { [unowned self] (photos) -> Observable<[UnsplashPhoto]> in
                var tempPhotos: [UnsplashPhoto] = []
                let existingPhotos = self.items.value
                if !existingPhotos.isEmpty {
                    tempPhotos.append(contentsOf: existingPhotos)
                }
                
                tempPhotos.append(contentsOf: photos)
                
                return .just(tempPhotos)
            }
            .bind(to: items)
        .disposed(by: disposeBag)
        
        
        
        
        
        
//            .flatMap({ [unowned self] (unsplashPhotos) -> Observable<[UnsplashPhoto]> in
//                var photos: [UnsplashPhoto] = []
//                let existingPhotos = self.loadedPhotos.value
//
//                if !existingPhotos.isEmpty {
//                    photos.append(contentsOf: existingPhotos)
//                }
//                photos.append(contentsOf: unsplashPhotos)
//                self.loadedPhotos.accept(photos)
//                return .from([photos])
//            })
//            .map { $0.map { [unowned self] photo -> UnsplashImageCollectionCommonItemViewModel in
//                let viewModel = UnsplashImageCollectionCommonItemViewModel(item: photo, cache: self.cache)
//                viewModel.outputs.detailRequest
//                    .asObservable()
//                    .subscribe(onNext: { () in
//                        self.detailObserver.accept(photo)
//                    })
//                    .disposed(by: self.disposeBag)
//                return viewModel
//                }}
//            .map{ $0.map { viewModel -> UnsplashCollectionItem in
//                .common(viewModel: viewModel)
//            }}
//            .flatMap({ (items) -> Observable<[UnsplashCollectionSection]> in
//                .just([.init(items: items)])
//            })
//        .bind(to: itemsPublisher)
//        .disposed(by: disposeBag)
    }
}


// MARK: Common Item


protocol UnsplashImageCollectionCommonItemViewModelOutput {
    var image: Driver<Data?> { get }
    var detailRequest: Signal<Void> { get }
}

protocol UnsplashImageCollectionCommonItemViewModelInput {
    var tapRequest: PublishRelay<Void> { get }
}

protocol UnsplashImageCollectionCommonItemViewModelType {
    var outputs: UnsplashImageCollectionCommonItemViewModelOutput { get }
    var inputs: UnsplashImageCollectionCommonItemViewModelInput { get }
}

class UnsplashImageCollectionCommonItemViewModel: UnsplashImageCollectionCommonItemViewModelType, UnsplashImageCollectionCommonItemViewModelOutput, UnsplashImageCollectionCommonItemViewModelInput {
    
    var outputs: UnsplashImageCollectionCommonItemViewModelOutput { return self }
    var inputs: UnsplashImageCollectionCommonItemViewModelInput { return self }
    
    // MARK: Outputs
    var image: Driver<Data?> {
        imageObserver.asDriver(onErrorJustReturn: nil)
    }
    
    var detailRequest: Signal<Void> {
        tapRequest.asSignal()
    }
    
    // MARK: Inputs
    let tapRequest = PublishRelay<Void>()
    
    // MARK: Private
    private let item: UnsplashPhoto
    private let cache: PhotoCacheType
    private let disposeBag = DisposeBag()
    
    private let imageObserver = PublishRelay<Data?>()
    
    // MARK: Init
    init(item: UnsplashPhoto, cache: PhotoCacheType) {
        self.item = item
        self.cache = cache
        
//        cache.fetchPhotoFor(url: URL(string: item.urls.small)!)
//            .subscribe(onNext: { [weak self] (data) in
//                self?.imageObserver.accept(data)
//            })
//        .disposed(by: disposeBag)
    }
}

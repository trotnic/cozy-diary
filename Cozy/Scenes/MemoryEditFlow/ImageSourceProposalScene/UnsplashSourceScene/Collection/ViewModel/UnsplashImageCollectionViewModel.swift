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

class UnsplashImageCollectionViewModel: UnsplashImageCollectionViewModelType, UnsplashImageCollectionViewModelOutput, UnsplashImageCollectionViewModelInput {
    
    var outputs: UnsplashImageCollectionViewModelOutput { return self }
    var inputs: UnsplashImageCollectionViewModelInput { return self }
    
    // MARK: Outputs
    var items: Driver<[UnsplashCollectionSection]> {
        itemsPublisher.asDriver()
    }
    
    var detailImageRequest: Signal<UnsplashPhoto> {
        detailObserver.asSignal()
    }
    
    var cancelObservable: Observable<Void> {
        willDisappear.asObservable()
    }
    
    // MARK: Inputs
    let didScrollToEnd = PublishRelay<Void>()
    let willDisappear = PublishRelay<Void>()
    let searchObserver = PublishRelay<String>()
    
    // MARK: Private
    private let pageCounter = BehaviorRelay<Int>(value: 0)
    
    private let service: UnsplashServiceType
    private let disposeBag = DisposeBag()
    
    private var loadedPhotos = BehaviorRelay<[UnsplashPhoto]>(value: [])
    
    private let itemsPublisher = BehaviorRelay<[UnsplashCollectionSection]>(value: [])
    private let detailObserver = PublishRelay<UnsplashPhoto>()
    
    // MARK: Init
    init(service: UnsplashServiceType) {
        self.service = service
        
        
        didScrollToEnd.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.pageCounter.accept(self.pageCounter.value + 1)
        })
        .disposed(by: disposeBag)
        
        pageCounter.subscribe(onNext: { [weak self] (page) in
            guard let self = self else { return }
            self.loadData(page: page)
        })
        .disposed(by: disposeBag)
        
        setupSearch()
    }
    
    
    // MARK: Private methods
    private func loadData(page: Int) {
        
        let result: Observable<[UnsplashPhoto]> = service.fetch(request: .photos(page: pageCounter.value, limit: 40))
            result
            .flatMap({ [unowned self] (unsplashPhotos) -> Observable<[UnsplashPhoto]> in
                var existingPhotos = self.loadedPhotos.value
                existingPhotos.append(contentsOf: unsplashPhotos)
                self.loadedPhotos.accept(existingPhotos)
                return .just(existingPhotos)
            })
            .map { $0.map { [unowned self] photo -> UnsplashImageCollectionCommonItemViewModel in
                let viewModel = UnsplashImageCollectionCommonItemViewModel(item: photo)
                viewModel.outputs.detailRequest
                    .asObservable()
                    .subscribe(onNext: { () in
                        self.detailObserver.accept(photo)
                    })
                    .disposed(by: self.disposeBag)
                return viewModel
                }}
            .map{ $0.map { viewModel -> UnsplashCollectionItem in
                .common(viewModel: viewModel)
            }}
            .flatMap({ (items) -> Observable<[UnsplashCollectionSection]> in
                .just([.init(items: items)])
            })
            .bind(to: itemsPublisher)
        .disposed(by: disposeBag)
    }
    
    private func setupSearch() {
        searchObserver
        .asObservable()
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .throttle(.microseconds(10000), scheduler: MainScheduler.instance)
            .flatMapLatest { [unowned self] (token) -> Observable<[UnsplashPhoto]> in
//                if let self = self {
            let result: Observable<UnsplashSearch> = self.service.fetch(request: .searchPhotos(term: token, page: 0, limit: 20))
            
            return result.flatMapLatest { (searchResults) -> Observable<[UnsplashPhoto]> in
                .just(searchResults.results)
            }
        }
        .map { $0.map { [unowned self] photo -> UnsplashImageCollectionCommonItemViewModel in
            let viewModel = UnsplashImageCollectionCommonItemViewModel(item: photo)
            viewModel.outputs.detailRequest
                .asObservable()
                .subscribe(onNext: { () in
                    self.detailObserver.accept(photo)
                })
                .disposed(by: self.disposeBag)
            return viewModel
            }}
        .map{ $0.map { viewModel -> UnsplashCollectionItem in
            .common(viewModel: viewModel)
        }}
        .flatMap({ (items) -> Observable<[UnsplashCollectionSection]> in
            .just([.init(items: items)])
        })
        .bind(to: itemsPublisher)
        .disposed(by: disposeBag)
    }
}


// MARK: Common Item


protocol UnsplashImageCollectionCommonItemViewModelOutput {
    var image: Driver<URL?> { get }
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
    var image: Driver<URL?> {
        imageObserver.asDriver()
    }
    
    var detailRequest: Signal<Void> {
        tapRequest.asSignal()
    }
    
    // MARK: Inputs
    let tapRequest = PublishRelay<Void>()
    
    // MARK: Private
    private let item: UnsplashPhoto
    private let disposeBag = DisposeBag()
    
    private let imageObserver = BehaviorRelay<URL?>(value: nil)
    
    // MARK: Init
    init(item: UnsplashPhoto) {
        self.item = item
        
        imageObserver.accept(URL(string: self.item.urls.small))
        
//        cache.fetchPhotoFor(url: URL(string: item.urls.small)!)
//            .subscribe(onNext: { [weak self] (data) in
//                self?.imageObserver.accept(data)
//            })
//        .disposed(by: disposeBag)
    }
}

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
        loadedPhotos
        .map { $0.map { [unowned self] (photo) -> UnsplashImageCollectionCommonItemViewModel in
            let viewModel = UnsplashImageCollectionCommonItemViewModel(item: photo)
        
            viewModel.outputs.detailRequest
            .asObservable()
                .subscribe(onNext: {
                    self.detailObserver.accept(photo)
                })
                .disposed(by: self.disposeBag)
            
            return viewModel
        }}
        .map { $0.map { viewModel -> UnsplashCollectionItem in
            .common(viewModel: viewModel)
            }}
        .flatMapLatest { (items) -> Observable<[UnsplashCollectionSection]> in
            .just([.init(items: items)])
        }
        .asDriver(onErrorJustReturn: [])
    }
    
    var detailImageRequest: Signal<UnsplashPhoto> { detailObserver.asSignal() }
    var cancelObservable: Observable<Void> { willDisappear.asObservable() }
    
    // MARK: Inputs
    let didScrollToEnd = PublishRelay<Void>()
    let willDisappear = PublishRelay<Void>()
    
    let searchObserver = PublishRelay<String>()
    let searchCancelObserver = PublishRelay<Void>()
    
    // MARK: Private
    private var currentPage = 1
    private var maxPageCount = 0
    private var currentSearchTerm = ""
    
    private let service: UnsplashServiceType
    private let disposeBag = DisposeBag()
    
    private var loadedPhotos = BehaviorRelay<[UnsplashPhoto]>(value: [])
    private let detailObserver = PublishRelay<UnsplashPhoto>()
    
    // MARK: Init
    init(service: UnsplashServiceType) {
        self.service = service
        
        setupSearch()
        bindScrollToEnd()
    }
    
    // MARK: Private methods
    private func loadData(term: String, page: Int) {
        
        let result: Observable<UnsplashSearch> = service.fetch(request: .searchPhotos(term: term, page: page, limit: 30))
        result
            .flatMapLatest { (searchResults) -> Observable<[UnsplashPhoto]> in
                .just(searchResults.results)
            }
            .subscribe(onNext: { [unowned self] (photos) in
                var existing = self.loadedPhotos.value
                existing.append(contentsOf: photos)
                self.loadedPhotos.accept(existing)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupSearch() {
        
        searchObserver
            .asObservable()
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .flatMapLatest { [unowned self] (term) -> Observable<(UnsplashSearch, String)> in

                let result: Observable<UnsplashSearch> = self.service.fetch(request: .searchPhotos(term: term, page: 1, limit: 30))
                
                return result.flatMapLatest { (results) -> Observable<(UnsplashSearch, String)> in
                    .just((results, term))
                }
            }
            .flatMapLatest({ [weak self] (searchResults, term) -> Observable<[UnsplashPhoto]> in
                self?.maxPageCount = searchResults.total_pages
                self?.currentPage = 1
                self?.currentSearchTerm = term
                return .just(searchResults.results)
            })
            .subscribe(onNext: { [unowned self] (photos) in
                self.loadedPhotos.accept([])
                var existing = self.loadedPhotos.value
                existing.append(contentsOf: photos)
                self.loadedPhotos.accept(existing)
            })
            .disposed(by: disposeBag)
        
        searchCancelObserver
            .asObservable()
            .subscribe(onNext: { (_) in
                
            })
            .disposed(by: disposeBag)
    }
    
    private func bindScrollToEnd() {
        didScrollToEnd
            .subscribe(onNext: { [weak self] () in
                if let self = self,
                    self.currentPage + 1 < self.maxPageCount {
                    self.currentPage += 1
                    self.loadData(term: self.currentSearchTerm, page: self.currentPage)
                }
            })
            .disposed(by: disposeBag)
    }
}


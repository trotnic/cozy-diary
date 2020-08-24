//
//  MemoryCollectionViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol MemoryCollectionViewModelOutput {
    var items: Observable<[MemoryCollectionViewSection]> { get }
    
    var detailRequestObservable: Observable<Memory> { get }
}

protocol MemoryCollectionViewModelInput {
    
}

protocol MemoryCollectionViewModelType {
    var outputs: MemoryCollectionViewModelOutput { get }
    var inputs: MemoryCollectionViewModelInput { get }
}

class MemoryCollectionViewModel: MemoryCollectionViewModelType, MemoryCollectionViewModelOutput, MemoryCollectionViewModelInput {
    
    var outputs: MemoryCollectionViewModelOutput { return self }
    var inputs: MemoryCollectionViewModelInput { return self }
    
    // MARK: Outputs
    lazy var items: Observable<[MemoryCollectionViewSection]> = {
        .just([
            .init(items: self.dataModeller
            .fetchAllMemories()
            .map { [unowned self] memory -> MemoryCollectionViewItem in
                let viewModel = MemoryCollectionCommonItemViewModel(memory: memory)
                viewModel.outputs.tapRequestObservable
                    .subscribe(onNext: { [weak self] in
                        self?.detailRequestPublisher.onNext(memory)
                    }).disposed(by: self.disposeBag)
                return .CommonItem(viewModel: viewModel)
        })])
    }()
    
    var detailRequestObservable: Observable<Memory>
    
    // MARK: Inputs
        
    // MARK: Private
    private let disposeBag = DisposeBag()
    private let dataModeller: CoreDataModeller
    
    private let detailRequestPublisher = PublishSubject<Memory>()
    
    // MARK: Init
    init(dataModeller: CoreDataModeller) {
        self.dataModeller = dataModeller
        
        detailRequestObservable = detailRequestPublisher.asObservable()
    }
    
}


// MARK: Collection Common Item View Model

protocol MemoryCollectionCommonItemViewModelOutput {
    var date: Observable<String> { get }
    var text: Observable<String> { get }
    
    var tapRequestObservable: Observable<Void> { get }
}

protocol MemoryCollectionCommonItemViewModelInput {
    var tapRequest: () -> () { get }
}

protocol MemoryCollectionCommonItemViewModelType {
    var outputs: MemoryCollectionCommonItemViewModelOutput { get }
    var inputs: MemoryCollectionCommonItemViewModelInput { get }
}

class MemoryCollectionCommonItemViewModel: MemoryCollectionCommonItemViewModelType, MemoryCollectionCommonItemViewModelOutput, MemoryCollectionCommonItemViewModelInput {
    
    var outputs: MemoryCollectionCommonItemViewModelOutput { return self }
    var inputs: MemoryCollectionCommonItemViewModelInput { return self }
    
    // MARK: Outputs
    lazy var date: Observable<String> = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let result = dateFormatter.string(from: memory.date)
        return .just(result)
    }()
    
    lazy var text: Observable<String> = {
        let result = memory.texts.first?.text.string ?? ""
        
        return .just(result)
    }()
    
    var tapRequestObservable: Observable<Void>
    
    // MARK: Inputs
    lazy var tapRequest = { { self.tapRequestPublisher.onNext(()) } }()
    
    // MARK: Private
    private let memory: Memory
    
    private let tapRequestPublisher = PublishSubject<Void>()
    
    
    init(memory: Memory) {
        self.memory = memory
        
        tapRequestObservable = tapRequestPublisher.asObservable()
    }
}

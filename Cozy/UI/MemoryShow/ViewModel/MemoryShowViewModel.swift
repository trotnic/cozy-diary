//
//  MemoryShowViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/20/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift



class MemoryShowViewModel: MemoryShowViewModelType {
    
    let memory: BehaviorRelay<Memory>
    private let disposeBag = DisposeBag()
    
    init(memory: Memory) {
        self.memory = .init(value: memory)
        items = .init(value: [])
        
        self.memory.subscribe(onNext: { [weak self] (memory) in
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
                            
//                            viewModel.tapRequest.subscribe(onNext: {
//                                self?.requestDetailImage.accept((chunk as! PhotoChunk).photo)
//                            }).disposed(by: self!.disposeBag)
                            
//                            viewModel.longPressRequest.subscribe(onNext: {
//                                print("LONG")
//                            }).disposed(by: self!.disposeBag)
                            
                            return .PhotoItem(viewModel: viewModel)
                        }
                    }
                )
        })
        .disposed(by: disposeBag)
    }
    
    
    var items: BehaviorRelay<[MemoryCreateCollectionItem]>! 
}

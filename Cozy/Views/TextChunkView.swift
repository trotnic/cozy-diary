//
//  MemoryTextView.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/16/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TextChunkView: UITextView, MemorizableView {

    private let viewModel: TextChunkViewModel
    private let disposeBag = DisposeBag()
    
    init(_ viewModel: TextChunkViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero, textContainer: nil)
        subscribe()
    }
    
    private func subscribe() {
        viewModel.text
            .bind(to: rx.text)
            .disposed(by: disposeBag)
        rx.text.orEmpty
            .bind(to: viewModel.text)
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func becomeFirstResponder() {
        
    }
    
}

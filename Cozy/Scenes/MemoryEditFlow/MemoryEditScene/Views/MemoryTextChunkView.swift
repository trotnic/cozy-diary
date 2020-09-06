//
//  MemoryTextChunkView.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/4/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift


class TextChunkMemoryView: UIView {
    private let disposeBag = DisposeBag()
    
    var viewModel: TextChunkViewModelType! {
        didSet {
            bindViewModel()
        }
    }
    
    lazy var textView: NMTextView = {
        let view = NMTextView()
        view.delegate = self
        view.isScrollEnabled = false
        view.sizeToFit()
        view.font = .systemFont(ofSize: 17)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(textView)
        textView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func bindViewModel() {
        viewModel
            .outputs
            .text
            .bind(to: textView.rx.attributedText)
            .disposed(by: disposeBag)
        
        textView.rx
            .attributedText
            .map { $0 ?? NSAttributedString(string: "") }
            .bind(to: viewModel.outputs.text)
            .disposed(by: disposeBag)
    }
    
    override func becomeFirstResponder() -> Bool {
        textView.becomeFirstResponder()
    }
    
}

extension TextChunkMemoryView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" && textView.text == "" {
            self.viewModel.inputs.contextRemoveTap.accept(())
        }
        return true
    }
}

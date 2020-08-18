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

class TextChunkMemoryCell: UICollectionViewCell {
    static let reuseIdentifier = "TextChunkMemoryCell"
    private let disposeBag = DisposeBag()
    var viewModel: TextChunkViewModel! {
        didSet {
            viewModel.text
                .bind(to: textView.rx.text)
                .disposed(by: disposeBag)
            textView.rx
                .text.orEmpty
                .bind(to: viewModel.text)
                .disposed(by: disposeBag)
        }
    }
    
    lazy var textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(textView)
        textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        textView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
    }
}

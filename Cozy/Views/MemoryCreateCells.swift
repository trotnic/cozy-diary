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

class TextChunkMemoryView: UIView {
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
        view.isScrollEnabled = false
        view.sizeToFit()
        
        view.font = .systemFont(ofSize: 20)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.rx.didChange.subscribe(onNext: { [weak self] in
            
            self?.viewModel.cellGrows.accept(())
        }).disposed(by: self.disposeBag)
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(textView)
        textView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
    }
    
}

class PhotoChunkMemoryView: UIView {
    private let disposeBag = DisposeBag()
    
    var viewModel: PhotoChunkViewModel! {
        didSet {
            viewModel.photo.map { UIImage(data: $0)}
                .bind(to: imageView.rx.image)
                .disposed(by: disposeBag)
            
            viewModel.photo.map { UIImage(data: $0)?.size }
                .subscribe(onNext: { [weak self] size in
                    if let size = size {
                        self?.imageView.invalidateIntrinsicContentSize()
                        self?.contentView.invalidateIntrinsicContentSize()
                        self?.imageView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
                        self?.imageView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
                        
                    }
                }).disposed(by: disposeBag)
            
            let tapReco = UITapGestureRecognizer()
            addGestureRecognizer(tapReco)
            tapReco.rx.event.subscribe(onNext: { [weak self] (reco) in
                self?.viewModel.tapRequest.accept(())
            }).disposed(by: disposeBag)
            
            let longPressReco = UILongPressGestureRecognizer()
            addGestureRecognizer(longPressReco)
            longPressReco.rx.event.subscribe(onNext: { [weak self] (reco) in
                if reco.state == .began {
                    self?.viewModel.longPressRequest.accept(())
                }
            }).disposed(by: disposeBag)
        }
    }
    
    lazy var contentView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(imageView)
        
        heightAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
}

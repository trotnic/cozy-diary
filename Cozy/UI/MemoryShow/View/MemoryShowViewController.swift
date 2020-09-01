//
//  MemoryShowViewController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/20/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol MemoryShowViewModelType {
    
    var items: BehaviorRelay<[MemoryCreateCollectionItem]>! { get }
    
}

class MemoryShowViewController: NMViewController {

    let viewModel: MemoryShowViewModelType
    private let disposeBag = DisposeBag()
    
    
    init(viewModel: MemoryShowViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var contentView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) has not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let safeGuide = view.safeAreaLayoutGuide
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor).isActive = true
        scrollView.contentInset.bottom = 150
        
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        
        scrollView.contentSize = contentView.bounds.size
        scrollView.sizeToFit()
        
        
        scrollView.backgroundColor = UIColor.white
        
        viewModel.items.map { $0.map { (item) -> UIView in
            switch item {
            case let .PhotoItem(viewModel):
                let view = PhotoChunkMemoryView()
                view.viewModel = viewModel
                return view
            case let .TextItem(viewModel):
                let view = TextChunkMemoryView()
                view.viewModel = viewModel
                return view
            case let .GraffitiItem(viewModel):
                let view = GraffitiChunkMemoryView()
                view.viewModel = viewModel
                return view
            }
            }}.subscribe(onNext: { [weak self] (views) in
                self?.contentView.removeAllArrangedSubviews()
                views.forEach { self?.contentView.addArrangedSubview($0) }
            }).disposed(by: disposeBag)
    }
}

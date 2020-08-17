//
//  MemoryCollectionViewController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol MemoryCollectionViewModelProtocol {
    var memories: BehaviorSubject<[Memory]> { get }
}

class MemoryCollectionViewController: BaseViewController {

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let bounds = UIScreen.main.bounds
        layout.itemSize = CGSize(width: bounds.width, height: 100)
        
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return view
    }()
    
    let viewModel: MemoryCollectionViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    init(viewModel: MemoryCollectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) not implemented")
    }
    
    override func loadView() {
        view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        bindData()
        
    }
    
    private func bindData() {
        viewModel.memories.bind(to:
        collectionView.rx.items(cellIdentifier: MemoryCollectionViewCell.reuseIdentifier, cellType: MemoryCollectionViewCell.self))
        { item, element, cell in
            cell.textLabel.text = "\(element.date)"
        }
        .disposed(by: disposeBag)
        
        
        
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(MemoryCollectionViewCell.self, forCellWithReuseIdentifier: MemoryCollectionViewCell.reuseIdentifier)
    }
}


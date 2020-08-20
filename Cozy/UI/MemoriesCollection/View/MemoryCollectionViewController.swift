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
import RxDataSources

protocol MemoryCollectionViewModelType {
    var items: BehaviorRelay<[MemoryCollectionViewSection]> { get }
}

enum MemoryCollectionViewItem {
    case CommonItem(viewModel: MemoryCollectionCommonItemViewModel)
}

struct MemoryCollectionViewSection {
    var items: [MemoryCollectionViewItem]
}

extension MemoryCollectionViewSection: SectionModelType {
    typealias Item = MemoryCollectionViewItem
    
    init(original: Self, items: [Self.Item]) {
        self = original
    }
}

struct MemoryCollectionViewDataSource {
    typealias DataSource = RxCollectionViewSectionedReloadDataSource
    
    static func dataSource() -> DataSource<MemoryCollectionViewSection> {
        return .init(configureCell: { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
            switch dataSource[indexPath] {
            case let .CommonItem(viewModel):
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemoryCollectionViewCell.reuseIdentifier, for: indexPath) as? MemoryCollectionViewCell {
                    cell.viewModel = viewModel
                    return cell
                }
                return UICollectionViewCell()
            }
        })
    }
}

class MemoryCollectionViewController: BaseViewController {
    
    var dataSource = MemoryCollectionViewDataSource.dataSource()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let bounds = UIScreen.main.bounds
        layout.itemSize = CGSize(width: bounds.width, height: 100)
        
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return view
    }()
    
    let viewModel: MemoryCollectionViewModelType
    private let disposeBag = DisposeBag()
    
    init(viewModel: MemoryCollectionViewModelType) {
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
        viewModel.items
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(MemoryCollectionViewCell.self, forCellWithReuseIdentifier: MemoryCollectionViewCell.reuseIdentifier)
    }
}


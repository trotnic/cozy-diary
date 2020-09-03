//
//  MemorySearchFilterController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/2/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources


// MARK: DataSource declaration

enum MemorySearchFilterCollectionItem {
    case tagsItem(viewModel: MemorySearchFilterTagsViewModelType)
    case monthsItem(value: String)
}

struct MemorySearchFilterCollectionSection {
    var items: [MemorySearchFilterCollectionItem]
}

extension MemorySearchFilterCollectionSection: SectionModelType {
    typealias Item = MemorySearchFilterCollectionItem
    
    init(original: Self, items: [Self.Item]) {
        self = original
    }
}

struct MemorySearchFilterCollectionDataSource {
    typealias DataSource = RxCollectionViewSectionedReloadDataSource
    
    static func dataSource() -> DataSource<MemorySearchFilterCollectionSection> {
        return .init(configureCell: { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
            switch item {
            case let .tagsItem(viewModel):
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemorySearchFilterTagCell.reuseIdentifier, for: indexPath) as? MemorySearchFilterTagCell {
                    cell.bindViewModel(viewModel)
                    return cell
                }
                return .init()
            case let .monthsItem(value):
//                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemorySearchFilterDateCell.reuseIdentifier, for: indexPath) as? MemorySearchFilterDateCell {
//                    cell.valueLabel.text = value
//                    return cell
//                }
                return .init()
            }
        })
    }
}

// MARK: View Model declaration

protocol MemorySearchFilterViewModelOutput {
    var items: Observable<[MemorySearchFilterCollectionSection]> { get }
}

protocol MemorySearchFilterViewModelInput {
    
}

protocol MemorySearchFilterViewModelType {
    var outputs: MemorySearchFilterViewModelOutput { get }
    var inputs: MemorySearchFilterViewModelInput { get }
}


class MemorySearchFilterController: NMViewController {

    
    private let dataSource = MemorySearchFilterCollectionDataSource.dataSource()
    
    let viewModel: MemorySearchFilterViewModelType
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: MemorySearchFilterViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var collectionView: NMCollectionView = {
        let layout = getLayout()
        let view = NMCollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(MemorySearchFilterDateCell.self, forCellWithReuseIdentifier: MemorySearchFilterDateCell.reuseIdentifier)
        view.register(MemorySearchFilterTagCell.self, forCellWithReuseIdentifier: MemorySearchFilterTagCell.reuseIdentifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = nil
        view.dataSource = nil
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel.outputs.items
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: Private methods
    private func setupCollectionView() {
        
        view.addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    fileprivate func getLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 7, leading: 14, bottom: 7, trailing: 14)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}

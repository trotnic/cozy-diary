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
    case monthsItem(viewModel: MemorySearchFilterMonthsViewModelType)
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
        return .init(configureCell: { (dataSource, tableView, indexPath, item) -> UICollectionViewCell in
            switch item {
            case let .tagsItem(viewModel):
                if let cell = tableView.dequeueReusableCell(withReuseIdentifier: MemorySearchFilterTagCell.reuseIdentifier, for: indexPath) as? MemorySearchFilterTagCell {
                    cell.bindViewModel(viewModel)
                    return cell
                }
                return .init()
            case let .monthsItem(viewModel):
                if let cell = tableView.dequeueReusableCell(withReuseIdentifier: MemorySearchFilterDateCell.reuseIdentifier, for: indexPath) as? MemorySearchFilterDateCell {
                    cell.bindViewModel(viewModel)
                    return cell
                }
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
    var cancelButtonTap: PublishRelay<Void> { get }
    var clearButtonTap: PublishRelay<Void> { get }
}

protocol MemorySearchFilterViewModelType {
    var outputs: MemorySearchFilterViewModelOutput { get }
    var inputs: MemorySearchFilterViewModelInput { get }
}


class MemorySearchFilterController: NMViewController {

    private let dataSource = MemorySearchFilterCollectionDataSource.dataSource()
    private let disposeBag = DisposeBag()
    
    let viewModel: MemorySearchFilterViewModelType
    
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
        return view
    }()
    
    lazy var clearButton: NMButton = {
        let view = NMButton()
        view.setTitle("Clear", for: .normal)
        return view
    }()
    
    lazy var cancelButton: NMButton = {
        let view = NMButton()
        view.setTitle("Cancel", for: .normal)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Filters"
        
        setupCollectionView()
        setupClearButton()
        setupCancelButton()
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
    
    private func setupClearButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: clearButton)
        
        clearButton.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                self?.viewModel.inputs.clearButtonTap.accept(())
                self?.dismiss(animated: true)
            })
        .disposed(by: disposeBag)
    }
    
    private func setupCancelButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                self?.viewModel.inputs.cancelButtonTap.accept(())
                self?.dismiss(animated: true)
            })
        .disposed(by: disposeBag)
    }
    
    fileprivate func getLayout() -> UICollectionViewCompositionalLayout {
        let height = NSCollectionLayoutDimension.estimated(200)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = .init(top: 7, leading: 14, bottom: 7, trailing: 14)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: height)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}

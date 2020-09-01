//
//  MemorySearchController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/25/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class MemorySearchController: NMViewController {
    
    var dataSource = MemoryCollectionViewDataSource.dataSource()

    fileprivate func getLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 7, leading: 14, bottom: 7, trailing: 14)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    lazy var collectionView: NMCollectionView = {
        let layout = getLayout()
        let view = NMCollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(MemoryCollectionViewCell.self, forCellWithReuseIdentifier: MemoryCollectionViewCell.reuseIdentifier)

        return view
    }()
    
    lazy var closeButton: NMButton = {
        let view = NMButton(type: .system)
        view.setTitle("Close", for: .normal)
        return view
    }()
    
    lazy var searchController: UISearchController = {
        let controller = NMSearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        return controller
    }()
    
    let viewModel: MemorySearchViewModelType
    private let disposeBag = DisposeBag()
    
    init(viewModel: MemorySearchViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        definesPresentationContext = true
        setupSearchController()
        setupCloseButton()
        setupCollectionView()
        
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel.outputs
            .items
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
            
    }
    
    private func setupSearchController() {
        searchController = NMSearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.placeholder = "Type something here to search"
        
        
        searchController.searchBar.rx
            .text.orEmpty
            .bind(to: viewModel.inputs.searchObserver)
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx
            .cancelButtonClicked
            .bind(to: viewModel.inputs.searchCancelObserver)
            .disposed(by: disposeBag)
        
        collectionView.rx.willBeginDragging
            .subscribe(onNext: { [weak self] in
                self?.searchController.searchBar.resignFirstResponder()
            })
        .disposed(by: disposeBag)
        
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupCloseButton() {
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.inputs.closeRequest()
            })
            .disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        
    }
}

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


class MemorySearchController: BaseViewController {
    
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
    
    lazy var collectionView: UICollectionView = {
        let layout = getLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(MemoryCollectionViewCell.self, forCellWithReuseIdentifier: MemoryCollectionViewCell.reuseIdentifier)

        return view
    }()
    
    lazy var closeButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("Close", for: .normal)
        return view
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
        
        view.backgroundColor = .white
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
        let searchContronller = UISearchController(searchResultsController: nil)
        searchContronller.searchBar.placeholder = "Type something here to search"
        
        
        searchContronller.searchBar.rx
            .text.orEmpty
            .bind(to: viewModel.inputs.searchObserver)
            .disposed(by: disposeBag)
        
        searchContronller.searchBar.rx
            .cancelButtonClicked
            .bind(to: viewModel.inputs.searchCancelObserver)
            .disposed(by: disposeBag)
        
        navigationItem.searchController = searchContronller
    }
    
    private func setupCollectionView() {
        
        view.addSubview(collectionView)
        
        
        let safeGuide = view.safeAreaLayoutGuide
        
        collectionView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    private func setupCloseButton() {
//        let button = UIBarButtonItem(title: "Close", style: .plain, target: nil, action: nil)
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.inputs.closeRequest()
            })
            .disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        
    }
}

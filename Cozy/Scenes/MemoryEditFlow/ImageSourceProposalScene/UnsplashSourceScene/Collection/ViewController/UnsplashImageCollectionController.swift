//
//  UnsplashImageCollectionController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/26/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher


class UnsplashImageCollectionController: NMViewController {
    let viewModel: UnsplashImageCollectionViewModelType
    
    // MARK: Private Properties
    private let disposeBag = DisposeBag()
    private let dataSource = UnsplashCollectionDataSource.dataSource()
    
    // MARK: Init
    init(viewModel: UnsplashImageCollectionViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Views
    lazy var collectionView: NMCollectionView = {
        let view = NMCollectionView(frame: .zero, collectionViewLayout: getLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var searchController: NMSearchController = {
        let controller = NMSearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        controller.searchBar.showsCancelButton = false
        controller.searchBar.placeholder = "Search for a photo"
        
        return controller
    }()
    
    lazy var noItemsLabel: NMLabel = {
        let view = NMLabel()
        view.text = "Find something amaizing for your memory ✨"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSearchController()
        setupBackButton()
        setupNoItemsLabel()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.searchBar.resignFirstResponder()
    }
        
    // MARK: Private Methods
    private func bindViewModel() {
        viewModel
            .outputs.items
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        collectionView
            .rx.willBeginDragging
            .subscribe(onNext: { [weak self] in
                self?.searchController.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        searchController
            .searchBar.rx
            .text.orEmpty
            .bind(onNext: { [weak self] (term) in
                self?.viewModel.inputs.searchObserver.accept(term)
                if term != "" {
                    self?.noItemsLabel.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        searchController
            .searchBar.rx
            .cancelButtonClicked
            .bind(to: viewModel.inputs.searchCancelObserver)
            .disposed(by: disposeBag)
    }
        
    private func getLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setupCollectionView() {
        collectionView.register(UnsplashCollectionCommonCell.self, forCellWithReuseIdentifier: UnsplashCollectionCommonCell.reuseIdentifier)
        
        view.addSubview(collectionView)
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        collectionView.contentInset.bottom = view.safeAreaInsets.bottom
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView
            .rx.willDisplayCell
            .flatMap { (_, indexPath) -> Observable<IndexPath> in .just(indexPath) }
            .filter { indexPath in
                let numberOfSections = self.collectionView.numberOfSections
                let numberOfElements = self.collectionView.numberOfItems(inSection: indexPath.section)
                return indexPath.section == numberOfSections - 1 && indexPath.item == numberOfElements - 1
            }
            .map { _ in () }
            .bind(to: viewModel.inputs.didScrollToEnd)
            .disposed(by: disposeBag)
    }
    
    private func setupSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let tapReco = UITapGestureRecognizer()
        tapReco
            .rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.searchController.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        collectionView.addGestureRecognizer(tapReco)
    }
    
    private func setupBackButton() {
        let button = NMButton()
        button.setTitle("Close", for: .normal)
        
        button
            .rx.tap
            .subscribe(onNext: { [weak self] in
                self?.searchController.searchBar.resignFirstResponder()
                if let controller = self?.navigationItem.searchController {
                    controller.dismiss(animated: true)
                }
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    private func setupNoItemsLabel() {
        view.addSubview(noItemsLabel)
        
        noItemsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noItemsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}


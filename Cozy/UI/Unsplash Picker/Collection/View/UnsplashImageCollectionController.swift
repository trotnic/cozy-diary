//
//  UnsplashImageCollectionController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/26/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import Kingfisher


// MARK: Data Source Configuration


enum UnsplashCollectionItem {
    case common(viewModel: UnsplashImageCollectionCommonItemViewModelType)
}

struct UnsplashCollectionSection {
    var items: [UnsplashCollectionItem]
}

extension UnsplashCollectionSection: SectionModelType {
    typealias Item = UnsplashCollectionItem
    
    init(original: Self, items: [Item]) {
        self = original
    }
}

struct UnsplashCollectionDataSource {
    typealias DataSource = RxCollectionViewSectionedReloadDataSource
    
    static func dataSource() -> DataSource<UnsplashCollectionSection> {
        return .init(configureCell: { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
            switch dataSource[indexPath] {
            case let .common(viewModel):
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UnsplashCollectionCommonCell.reuseIdentifier, for: indexPath) as? UnsplashCollectionCommonCell {
                    cell.viewModel = viewModel
                    return cell
                }
                return .init()
            }
        })
    }
}


// MARK: Controller


class UnsplashImageCollectionController: BaseViewController {
    
    let viewModel: UnsplashImageCollectionViewModelType
    
    let service = UnsplashService()
    
    
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
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: getLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        setupCollectionView()
        bindViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func bindViewModel() {
        
        viewModel.outputs.items
            .drive(collectionView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
    }
    
    func setupCollectionView() {
        collectionView.register(UnsplashCollectionCommonCell.self, forCellWithReuseIdentifier: UnsplashCollectionCommonCell.reuseIdentifier)
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        
        let safeGuide = view.safeAreaLayoutGuide
        collectionView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor).isActive = true
        
        collectionView.rx.willDisplayCell
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
    
    // MARK: Private Methods
    private func getLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
        
    }
    
}


// MARK: Common Cell


class UnsplashCollectionCommonCell: UICollectionViewCell {
    
    static let reuseIdentifier = "UnsplashCollectionCommonCell"
    
    var viewModel: UnsplashImageCollectionCommonItemViewModelType! {
        didSet {
            bindViewModel()
        }
    }
    
    // MARK: Private properties
    private let disposeBag = DisposeBag()
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImageView()
        setupTapRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Subviews
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Private methods
    private func setupImageView() {
        contentView.addSubview(imageView)
        
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    private func setupTapRecognizer() {
        let tapReco = UITapGestureRecognizer()
        tapReco.rx.event
            .subscribe(onNext: { [weak self] (recognizer) in
                self?.viewModel.inputs.tapRequest.accept(())
            })
        .disposed(by: disposeBag)
        addGestureRecognizer(tapReco)
    }
    
    private func bindViewModel() {
        viewModel.outputs.image.drive(onNext: { [weak self] (url) in
            if let url = url {
                self?.imageView.kf.indicatorType = .activity
                self?.imageView.kf
                    .setImage(with: url, options: [.transition(.fade(0.25))])
            }
        })
        .disposed(by: disposeBag)
    }
}

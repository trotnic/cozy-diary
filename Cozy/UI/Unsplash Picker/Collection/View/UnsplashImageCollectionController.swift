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
    private var cachedImages: [Int: UIImage] = [:]
    
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
        
//        viewModel.inputs.viewDidLoad.accept(())
    }
    
    func bindViewModel() {
        
        viewModel.outputs.items
            .bind(to: collectionView.rx.items(cellIdentifier: UnsplashCollectionCommonCell.reuseIdentifier, cellType: UnsplashCollectionCommonCell.self)) { _, _, _ in }
        .disposed(by: disposeBag)
        
        collectionView.rx.willDisplayCell
            .filter { $0.cell.isKind(of: UnsplashCollectionCommonCell.self) }
            .map { ($0.cell as! UnsplashCollectionCommonCell, $0.at.item)}
            .do(onNext: { (cell, index) in
                cell.imageView.image = nil
            })
            .subscribe(onNext: { [weak self] (cell, index) in
//                if let cachedImage = self?.cachedImages[index] {
//                    cell.imageView.image = cachedImage
//                } else {
                    self?.viewModel.inputs.willDisplayCellAtIndex.accept(index)
//                }
            })
        .disposed(by: disposeBag)
        
        viewModel.outputs.imageRetrievedSuccess
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (image, index) in
                if let cell = self?.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? UnsplashCollectionCommonCell {
                    cell.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                    UIView.animate(withDuration: 0.2) {
                        cell.transform = .identity
                    }
                    cell.imageView.image = image
                    
//                    self?.cachedImages[index] = image
                }
            })
        .disposed(by: disposeBag)
        
        viewModel.outputs.imageRetrievedError
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (index) in
                if let cell = self?.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? UnsplashCollectionCommonCell {
                    cell.imageView.image = nil
                }
            })
        .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(UnsplashPhoto.self)
            .compactMap { $0.id }
            .bind(to: viewModel.inputs.didSelectModelWithId)
        .disposed(by: disposeBag)
        
        collectionView.rx.willDisplayCell
            .flatMap { (cell, indexPath) -> Observable<(section: Int, row: Int)> in
                return .of((indexPath.section, indexPath.row))
        }
        .filter { (section, row) in
            let numberOfSections = self.collectionView.numberOfSections
            let numberOfItems = self.collectionView.numberOfItems(inSection: section)

            return section == numberOfSections - 1 && row == numberOfItems - 5
        }
        .map { _ in () }
        .bind(to: viewModel.inputs.didScrollToTheBottom)
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
        
//        collectionView.rx.willDisplayCell
//            .flatMap({ (_, indexPath) -> Observable<(section: Int, row: Int)> in
//                return Observable.of((indexPath.section, indexPath.row))
//            })
//            .filter { (section, row) in
//                let numberOfSections = self.collectionView.numberOfSections
//                let numberOfItems = self.collectionView.numberOfItems(inSection: section)
//
//                return section == numberOfSections - 1
//                    && row == numberOfItems - 1
//            }
//            .map { _ in () }
//            .bind(to: viewModel.inputs.didScrollToEnd)
//        .disposed(by: disposeBag)
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
            viewModel.outputs.image
                .drive(onNext: { [weak self] (data) in
                    if let data = data {
                        self?.imageView.image = UIImage(data: data)
                    }
                })
            .disposed(by: disposeBag)
        }
    }
    
    // MARK: Private properties
    private let disposeBag = DisposeBag()
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        let tapReco = UITapGestureRecognizer()
//        tapReco.rx.event
//            .subscribe(onNext: { [weak self] (recognizer) in
//                self?.viewModel.inputs.tapRequest.accept(())
//                self?.contentView.layoutIfNeeded()
//            })
//        .disposed(by: disposeBag)
//
//        addGestureRecognizer(tapReco)
        
        
        contentView.addSubview(imageView)
        
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}

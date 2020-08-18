//
//  MemoryCreateViewController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

protocol MemoryCreateViewModelProtocol {
    
    var viewDidLoad: PublishRelay<Void> { get }
    var viewDidAddTextChunk: PublishRelay<Void> { get }
    var currentMemory: BehaviorRelay<Memory> { get }
    var items: BehaviorRelay<[MemoryCreateCollectionSection]>! { get }
    var dataSource: RxCollectionViewSectionedReloadDataSource<MemoryCreateCollectionSection> { get }
}

enum MemoryCreateCollectionItem {
    case TextItem(viewModel: TextChunkViewModel)
}

struct MemoryCreateCollectionSection {
    var items: [MemoryCreateCollectionItem]
}

extension MemoryCreateCollectionSection: SectionModelType {
    typealias Item = MemoryCreateCollectionItem
    
    init(original: Self, items: [Self.Item]) {
        self = original
    }
}

struct MemoryCreateDataSource {
    typealias DataSource = RxCollectionViewSectionedReloadDataSource
    
    static func dataSource() -> DataSource<MemoryCreateCollectionSection> {
        return .init(configureCell: { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
            switch dataSource[indexPath] {
            case let .TextItem(viewModel):
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextChunkMemoryCell.reuseIdentifier, for: indexPath) as? TextChunkMemoryCell {
                    cell.viewModel = viewModel
                    return cell
                }
                return UICollectionViewCell()
            }
        })
    }
}


class MemoryCreateViewController: BaseViewController {

    let viewModel: MemoryCreateViewModelProtocol
    
    init(_ viewModel: MemoryCreateViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) not implemented")
    }
    
    lazy var dateLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: UIScreen.main.bounds.width, height: 150)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(TextChunkMemoryCell.self, forCellWithReuseIdentifier: TextChunkMemoryCell.reuseIdentifier)
        return view
    }()
    
    private let disposeBag = DisposeBag()
    private var currentMemory: MemorizableView!
    
    override func loadView() {
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad.accept(())
        setupCollectionView()
    }
    
    func setupCollectionView() {
        viewModel.items
            .bind(to: collectionView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
        
        
        let tapGesture = UITapGestureRecognizer()
        
        collectionView.addGestureRecognizer(tapGesture)
        collectionView.backgroundColor = .white
        tapGesture
            .rx.event
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self] recognizer in
                self?.viewModel.viewDidAddTextChunk.accept(())
        }
        .disposed(by: disposeBag)
    }
}


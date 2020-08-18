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
    
    var viewDidAddPhotoChunk: PublishRelay<Data> { get }
    
    var currentMemory: BehaviorRelay<Memory> { get }
    var items: BehaviorRelay<[MemoryCreateCollectionSection]>! { get }
    var dataSource: RxCollectionViewSectionedReloadDataSource<MemoryCreateCollectionSection> { get }
}

enum MemoryCreateCollectionItem {
    case TextItem(viewModel: TextChunkViewModel)
    case PhotoItem(viewModel: PhotoChunkViewModel)
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
            case let .PhotoItem(viewModel):
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoChunkMemoryCell.reuseIdentifier, for: indexPath) as? PhotoChunkMemoryCell {
                    cell.viewModel = viewModel
                    return cell
                }
                return UICollectionViewCell()
            }
        })
    }
}


class MemoryCreateViewController: BaseViewController {
    let imagePicker = ImagePicker()

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
        view.register(PhotoChunkMemoryCell.self, forCellWithReuseIdentifier: PhotoChunkMemoryCell.reuseIdentifier)
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
        setupPhotoButton()
    }
    
    func setupPhotoButton() {
        let button = UIBarButtonItem(image: .add, style: .plain, target: nil, action: nil)
        // FIXME
        button.rx.tap.subscribe(onNext: { [weak self] in self?.dothings() }).disposed(by: disposeBag)
        navigationItem.rightBarButtonItem = button
    }
    
    func dothings() {
        setupAlertController(onView: view) { [weak self] (controller) in
            self?.present(controller, animated: true)
        }
        
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
    
    private func setupAlertController(onView: UIView, _ completion: @escaping (UIAlertController) -> ()) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { [weak self] _ in
            self?.imagePicker.prepareGallery({ (controller) in
                self?.present(controller, animated: true)
            }, completion: { data in
                self?.dismiss(animated: true)
                if let image = data.originalImage {
                    self?.viewModel.viewDidAddPhotoChunk.accept(image)
                }                
            })
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = onView
            alert.popoverPresentationController?.sourceRect = onView.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        completion(alert)
    }
}



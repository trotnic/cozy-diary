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

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}

protocol MemoryCreateViewModelProtocol {
    
    // inputs
    
    var viewDidLoad: PublishRelay<Void> { get }
    
    var textChunkRequest: PublishRelay<Void> { get }
    var photoChunkRequest: PublishRelay<Data> { get }
    
    // outputs
    
    var textChunkGrows: PublishRelay<Void> { get }
    var items: BehaviorRelay<[MemoryCreateCollectionItem]>! { get }
}

enum MemoryCreateCollectionItem {
    case TextItem(viewModel: TextChunkViewModel)
    case PhotoItem(viewModel: PhotoChunkViewModel)
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
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var contentView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad.accept(())
        setupScrollView()
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
    
    func setupScrollView() {
        let safeGuide = view.safeAreaLayoutGuide
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor).isActive = true
        scrollView.contentInset.bottom = 150
        
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        
        scrollView.contentSize = contentView.bounds.size
        scrollView.sizeToFit()
        
        
        scrollView.backgroundColor = UIColor.white
        
        viewModel.items.map { $0.map { $0.map { (item) -> UIView in
            switch item {
            case let .PhotoItem(viewModel):
                let view = PhotoChunkMemoryView()
                view.viewModel = viewModel
                return view
            case let .TextItem(viewModel):
                let view = TextChunkMemoryView()
                view.viewModel = viewModel
                return view
            }
            }}}?.subscribe(onNext: { [weak self] (views) in
                self?.contentView.removeAllArrangedSubviews()
                views.forEach { self?.contentView.addArrangedSubview($0) }
            }).disposed(by: disposeBag)
//        viewModel.items
//            .bind(to: collectionView.rx.items(dataSource: viewModel.dataSource))
//            .disposed(by: disposeBag)
        
        
        let tapGesture = UITapGestureRecognizer()
//        collectionView.addGestureRecognizer(tapGesture)
//        collectionView.backgroundColor = .white
        scrollView.addGestureRecognizer(tapGesture)
        tapGesture
            .rx.event
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self] recognizer in
                self?.viewModel.textChunkRequest.accept(())
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
                    self?.viewModel.photoChunkRequest.accept(image)
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

//
//  MemoryPhotoChunkView.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/4/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class PhotoChunkMemoryView: UIView {
    
    // MARK: Outputs
    var tapDriver: Driver<Void> {
        tapObserver.asDriver(onErrorJustReturn: ())
    }
    
    // MARK: Private
    private let disposeBag = DisposeBag()
    private let tapObserver = PublishRelay<Void>()
    
    var imageViewLeadingAnchor: NSLayoutConstraint!
    var imageViewTrailingAnchor: NSLayoutConstraint!
    
    var viewModel: PhotoChunkViewModelType! {
        didSet {
            bindViewModel()
        }
    }
    
    lazy var contentView: NMView = {
        let view = NMView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var imageView: NMImageView = {
        let view = NMImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
        
        addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        
        imageViewLeadingAnchor = imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        imageViewTrailingAnchor = imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageViewLeadingAnchor.isActive = true
        imageViewTrailingAnchor.isActive = true
        
    }
    
    func bindViewModel() {
        viewModel.outputs.photo.map { UIImage(data: $0)}
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.outputs.photo.map { UIImage(data: $0)?.size }
            .subscribe(onNext: { [weak contentView] size in
                if let contentView = contentView,
                    let size = size {
                    contentView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: size.height/size.width).isActive = true
                }
            }).disposed(by: disposeBag)
        
        let tapReco = UITapGestureRecognizer()
        addGestureRecognizer(tapReco)
        tapReco.rx.event.subscribe(onNext: { [weak self] (reco) in
            self?.tapObserver.accept(())
            self?.viewModel.inputs.tapRequest()
        }).disposed(by: disposeBag)
    }
    
}

extension PhotoChunkMemoryView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            return self.createContextMenu()
        }
    }
    
    func createContextMenu() -> UIMenu {

        let shareAction = UIAction(
            title: "Share",
            image: UIImage(systemName: "square.and.arrow.up"),
            handler: { [weak self] _ in
                self?.viewModel.inputs.shareButtonTap.accept(())
        })
        
        let copy = UIAction(
            title: "Copy",
            image: UIImage(systemName: "doc.on.doc"),
            handler: { [weak self] _ in
                self?.viewModel.inputs.copyButtonTap.accept(())
        })
        
        let remove = UIAction(
            title: "Remove",
            image: UIImage(systemName: "trash")?.withTintColor(.red),
            handler: { [weak self] _ in
                self?.viewModel.inputs.removeButtonTap.accept(())
        })
        
        return UIMenu(title: "", children: [shareAction, copy, remove])
    }
}

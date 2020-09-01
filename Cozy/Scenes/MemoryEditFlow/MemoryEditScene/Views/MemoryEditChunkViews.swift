//
//  MemoryTextView.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/16/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift




// MARK: Text Chunk View Model Declaration


protocol TextChunkViewModelOutput {
    var text: BehaviorRelay<NSAttributedString> { get }
    
    var removeTextRequest: Observable<Void> { get }
}

protocol TextChunkViewModelInput {
    var tapRequest: () -> () { get }
    var longPressRequest: () -> () { get }
    
    var contextRemoveRequest: () -> () { get }
}

protocol TextChunkViewModelType {
    var outputs: TextChunkViewModelOutput { get }
    var inputs: TextChunkViewModelInput { get }
}


// MARK: Text Chunk View


class TextChunkMemoryView: UIView {
    private let disposeBag = DisposeBag()
    
    var viewModel: TextChunkViewModelType! {
        didSet {
            bindViewModel()
        }
    }
    
    lazy var textView: NMTextView = {
        let view = NMTextView()
        view.delegate = self
        view.isScrollEnabled = false
        view.sizeToFit()
        view.font = .systemFont(ofSize: 17)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(textView)
        textView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func bindViewModel() {
        viewModel.outputs.text
            .bind(to: textView.rx.attributedText)
            .disposed(by: disposeBag)
        textView.rx
            .attributedText
            .map { $0 ?? NSAttributedString(string: "") }
            .bind(to: viewModel.outputs.text)
            .disposed(by: disposeBag)
        
        let tapReco = UITapGestureRecognizer()
        addGestureRecognizer(tapReco)
        tapReco.rx.event.subscribe(onNext: { [weak self] (reco) in
            self?.viewModel.inputs.tapRequest()
        }).disposed(by: disposeBag)
        
        let longPressReco = UILongPressGestureRecognizer()
        addGestureRecognizer(longPressReco)
        longPressReco.rx.event.subscribe(onNext: { [weak self] (reco) in
            if reco.state == .began {
                self?.viewModel.inputs.longPressRequest()
            }
        }).disposed(by: disposeBag)
    }
    
    override func becomeFirstResponder() -> Bool {
        textView.becomeFirstResponder()
    }
    
}

extension TextChunkMemoryView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" && textView.text == "" {
            self.viewModel.inputs.contextRemoveRequest()
        }
        return true
    }
}


// MARK: Photo Chunk View Model Declaration


protocol PhotoChunkViewModelOutput {
    var photo: BehaviorRelay<Data> { get }
    
    var detailPhotoRequestObservable: Observable<Void> { get }
    
    var sharePhotoRequest: Observable<Void> { get }
    var copyPhotoRequest: Observable<Void> { get }
    var removePhotoRequest: Observable<Void> { get }
}

protocol PhotoChunkViewModelInput {
    var tapRequest: () -> () { get }
    var longPressRequest: () -> () { get }
    
    var contextShareRequest: () -> () { get }
    var contextCopyRequest: () -> () { get }
    var contextRemoveRequest: () -> () { get }
}

protocol PhotoChunkViewModelType {
    var outputs: PhotoChunkViewModelOutput { get }
    var inputs: PhotoChunkViewModelInput { get }
}


// MARK: Photo Chunk View


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
                self?.viewModel.inputs.contextShareRequest()
        })
        
        let copy = UIAction(
            title: "Copy",
            image: UIImage(systemName: "doc.on.doc"),
            handler: { [weak self] _ in
                self?.viewModel.inputs.contextCopyRequest()
        })
        
        let remove = UIAction(
            title: "Remove",
            image: UIImage(systemName: "trash")?.withTintColor(.red),
            handler: { [weak self] _ in
                self?.viewModel.inputs.contextRemoveRequest()
        })
        
        return UIMenu(title: "", children: [shareAction, copy, remove])
    }
}


// MARK: Graffiti Chunk View Model Declaration


protocol GraffitiChunkViewModelOutput {
    var graffiti: Observable<Data> { get }
    
    var sharePhotoRequest: Observable<Void> { get }
    var copyPhotoRequest: Observable<Void> { get }
    var removePhotoRequest: Observable<Void> { get }
}

protocol GraffitiChunkViewModelInput {
    
    var contextShareRequest: () -> () { get }
    var contextCopyRequest: () -> () { get }
    var contextRemoveRequest: () -> () { get }
}

protocol GraffitiChunkViewModelType {
    var outputs: GraffitiChunkViewModelOutput { get }
    var inputs: GraffitiChunkViewModelInput { get }
}


// MARK: Graffiti Chunk View


class GraffitiChunkMemoryView: UIView {
    private let disposeBag = DisposeBag()
    
    var viewModel: GraffitiChunkViewModelType! {
        didSet {
            bindViewModel()
        }
    }
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var graffitiView: NMImageView = {
        let view = NMImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
        
        addSubview(graffitiView)
        
        graffitiView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        graffitiView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        graffitiView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        graffitiView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel() {
        viewModel.outputs.graffiti
            .map { data in UIImage(data: data) }
            .bind(to: graffitiView.rx.image)
            .disposed(by: disposeBag)
    }
}

extension GraffitiChunkMemoryView: UIContextMenuInteractionDelegate {
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
                self?.viewModel.inputs.contextShareRequest()
        })
        
        let copy = UIAction(
            title: "Copy",
            image: UIImage(systemName: "doc.on.doc"),
            handler: { [weak self] _ in
                self?.viewModel.inputs.contextCopyRequest()
        })
        
        let remove = UIAction(
            title: "Remove",
            image: UIImage(systemName: "trash")?.withTintColor(.red),
            handler: { [weak self] _ in
                self?.viewModel.inputs.contextRemoveRequest()
        })
        
        return UIMenu(title: "", children: [shareAction, copy, remove])
    }
}

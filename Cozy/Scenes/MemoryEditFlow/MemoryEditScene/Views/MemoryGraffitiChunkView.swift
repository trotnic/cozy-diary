//
//  MemoryGraffitiChunkView.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/4/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class GraffitiChunkMemoryView: UIView {
    private let disposeBag = DisposeBag()
    
    var viewModel: GraffitiChunkViewModelType! { didSet { bindViewModel() } }
    
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
        viewModel
            .outputs
            .graffiti
            .map { data in UIImage(data: data) }
            .bind(to: graffitiView.rx.image)
            .disposed(by: disposeBag)
    }
}

extension GraffitiChunkMemoryView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in self.createContextMenu() }
    }
    
    func createContextMenu() -> UIMenu {

        let shareAction = UIAction(
            title: "Share",
            image: UIImage(systemName: "square.and.arrow.up"),
            handler: { [weak self] _ in self?.viewModel.inputs.shareButtonTap.accept(()) })
        
        let copy = UIAction(
            title: "Copy",
            image: UIImage(systemName: "doc.on.doc"),
            handler: { [weak self] _ in self?.viewModel.inputs.copyButtonTap.accept(()) })
        
        let remove = UIAction(
            title: "Remove",
            image: UIImage(systemName: "trash"),
            identifier: nil,
            discoverabilityTitle: nil,
            attributes: .destructive,
            state: .off,
            handler: { [weak self] _ in self?.viewModel.inputs.removeButtonTap.accept(()) })
        
        return UIMenu(title: "", children: [shareAction, copy, remove])
    }
}


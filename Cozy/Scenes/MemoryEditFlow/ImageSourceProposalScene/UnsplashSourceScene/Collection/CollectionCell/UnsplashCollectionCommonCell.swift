//
//  UnsplashCollectionCommonCell.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/28/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift




class UnsplashCollectionCommonCell: UICollectionViewCell {
    
    static let reuseIdentifier = "UnsplashCollectionCommonCell"
    
    var viewModel: UnsplashImageCollectionCommonItemViewModelType! { didSet { bindViewModel() } }
    
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
        
        tapReco
            .rx.event
            .subscribe(onNext: { [weak self] (recognizer) in
                self?.viewModel.inputs.tapRequest.accept(())
            })
            .disposed(by: disposeBag)
        
        addGestureRecognizer(tapReco)
    }
    
    private func bindViewModel() {
        viewModel
            .outputs
            .image
            .drive(onNext: { [weak self] (url) in
                if let url = url {
                    self?.imageView.kf.indicatorType = .activity
                    self?.imageView.kf
                        .setImage(with: url, options: [.transition(.fade(0.25))])
                }
            })
            .disposed(by: disposeBag)
    }
}


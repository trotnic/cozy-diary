//
//  MemorySearchFilterCollectionCell.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/2/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

// MARK: Tags


class MemorySearchFilterTagCell: NMCollectionViewCell {
    static let reuseIdentifier = "MemorySearchFilterTagCell"
    
    private var viewModel: MemorySearchFilterTagsViewModelType!
    private let disposeBag = DisposeBag()
    private var widthConstraint: NSLayoutConstraint!
    
    lazy var collectionView: NMCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .init(width: 10, height: 10)
        let view = NMCollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(FilterTagCell.self, forCellWithReuseIdentifier: FilterTagCell.reuseIdentifier)
        view.delegate = nil
        view.dataSource = nil
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(_ viewModel: MemorySearchFilterTagsViewModelType) {
        self.viewModel = viewModel
        
        viewModel
            .outputs
            .items
            .bind(to: collectionView.rx.items(cellIdentifier: FilterTagCell.reuseIdentifier, cellType: FilterTagCell.self)) { item, model, cell in
                cell.bindModel(model)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupLabel() {
        
        addSubview(collectionView)
        
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        collectionView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
    }
}

class FilterTagCell: NMCollectionViewCell {
    static let reuseIdentifier = "FilterTagCell"
    
    private var tagModel: BehaviorRelay<TagModel>! {
        didSet {
            bindBehavior()
        }
    }
    
    private let disposeBag = DisposeBag()
    
    lazy var textLabel: NMLabel = {
        let view = NMLabel()
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextLabel()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindModel(_ model: BehaviorRelay<TagModel>) {
        self.tagModel = model
    }
    
    private func bindBehavior() {
        tagModel.bind { [weak self] (tagModel) in
            self?.textLabel.text = tagModel.value
            self?.isSelected = tagModel.isSelected
            
            if tagModel.isSelected {
                self?.layer.shadowOffset = CGSize(width: -2, height: -2)                
            } else {
                self?.layer.shadowOffset = CGSize(width: 2, height: 2)
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func setupTextLabel() {
        contentView.addSubview(textLabel)
        
        textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    }
    
    private func setupView() {
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 2)

        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let value = tagModel.value
        value.isSelected.toggle()
        tagModel.accept(value)
    }
    
}


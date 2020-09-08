//
//  MemorySearchFilterDateCell.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/3/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class MemorySearchFilterDateCell: NMCollectionViewCell {
    static let reuseIdentifier = "MemorySearchFilterDateCell"
    
    private var viewModel: MemorySearchFilterMonthsViewModelType!
    private let disposeBag = DisposeBag()
    private var widthConstraint: NSLayoutConstraint!
    
    lazy var collectionView: NMCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .init(width: 10, height: 10)
        let view = NMCollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(FilterMonthCell.self, forCellWithReuseIdentifier: FilterMonthCell.reuseIdentifier)
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
    
    func bindViewModel(_ viewModel: MemorySearchFilterMonthsViewModelType) {
        self.viewModel = viewModel
        
        viewModel.outputs.items
            .bind(to: collectionView.rx.items(cellIdentifier: FilterMonthCell.reuseIdentifier, cellType: FilterMonthCell.self)) { item, model, cell in
                cell.bindModel(model)
        }
        .disposed(by: disposeBag)
    }
    
    private func setupLabel() {
        contentView.addSubview(collectionView)
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        contentView.heightAnchor.constraint(equalTo: collectionView.heightAnchor, multiplier: 1.2).isActive = true
        collectionView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
    }
}


class FilterMonthCell: NMCollectionViewCell {
    static let reuseIdentifier = "FilterMonthCell"
    
    private var monthModel: BehaviorRelay<MonthModel>! {
        didSet {
            bindBehavior()
        }
    }
    
    private let disposeBag = DisposeBag()
    
    lazy var textLabel: NMLabel = {
        let view = NMLabel()
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
    
    func bindModel(_ model: BehaviorRelay<MonthModel>) {
        self.monthModel = model
    }
    
    private func bindBehavior() {
        monthModel.bind { [weak self] (monthModel) in
            switch monthModel.value {
            case let .january(value, _),
                 let .february(value, _),
                 let .march(value, _),
                 let .april(value, _),
                 let .may(value, _),
                 let .june(value, _),
                 let .july(value, _),
                 let .august(value, _),
                 let .september(value, _),
                 let .october(value, _),
                 let .november(value, _),
                 let .december(value, _):
                self?.textLabel.text = value
            }
            
            self?.isSelected = monthModel.isSelected
            
            if monthModel.isSelected {
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
        let value = monthModel.value
        value.isSelected.toggle()
        monthModel.accept(value)
    }
    
}

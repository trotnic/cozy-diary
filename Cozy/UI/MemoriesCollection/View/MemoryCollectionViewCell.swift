//
//  MemoryCollectionViewCell.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


class MemoryCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier: String = "MemoryCollectionViewCell"
    
    private let disposeBag = DisposeBag()
    
    var viewModel: MemoryCollectionCommonItemViewModelType! {
        didSet {
            bindViewModel()
        }
    }
    
    lazy var dateLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 17)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var textLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = .white
        let safeGuide = contentView.safeAreaLayoutGuide
        
        contentView.addSubview(dateLabel)
        dateLabel.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor, constant: 20).isActive = true
        dateLabel.topAnchor.constraint(equalTo: safeGuide.topAnchor, constant: 5).isActive = true
        
        contentView.addSubview(textLabel)
        textLabel.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor, constant: 10).isActive = true
        textLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor, constant: -10).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor, constant: -10).isActive = true
        
        // Shadow
        layer.cornerRadius = 10
        layer.shadowOpacity = 0.2
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowRadius = 3
        
        
    }
    
    func bindViewModel() {
        viewModel.outputs.date
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.text
            .bind(to: textLabel.rx.text)
            .disposed(by: disposeBag)
        
        bindGestures()
    }
    
    func bindGestures() {
        let tapReco = UITapGestureRecognizer()
        addGestureRecognizer(tapReco)
        
        tapReco.rx.event
            .subscribe(onNext: { [weak self] (recognizer) in
                self?.viewModel.inputs.tapRequest()
        }).disposed(by: disposeBag)
    }
    
}

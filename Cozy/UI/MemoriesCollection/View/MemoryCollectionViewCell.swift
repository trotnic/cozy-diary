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
    
    private let disposeBag = DisposeBag()
    
    var viewModel: MemoryCollectionCommonItemViewModel! {
        didSet {
            viewModel.date
                .bind(to: textLabel.rx.text)
                .disposed(by: disposeBag)
        }
    }
    
    static let reuseIdentifier: String = "MemoryCollectionViewCell"
    
    lazy var textLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bindGestures()
        contentView.addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        backgroundColor = .gray
        
        
        let safeGuide = contentView.safeAreaLayoutGuide
        textLabel.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor).isActive = true
    }
    
    func bindGestures() {
        let tapReco = UITapGestureRecognizer()
        addGestureRecognizer(tapReco)
        
        tapReco.rx.event.subscribe(onNext: { [weak self] (recognizer) in
            if let strongSelf = self {
                strongSelf.viewModel.cellReceiveTap.accept(())
//                strongSelf.viewModel.cellReceiveTap.accept(())
            }
        }).disposed(by: disposeBag)
    }
    
}

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


class MemoryCollectionViewCell: NMCollectionViewCell {
    static let reuseIdentifier: String = "MemoryCollectionViewCell"
    
    private let disposeBag = DisposeBag()
    
    var viewModel: MemoryCollectionCommonItemViewModelType! {
        didSet {
            bindViewModel()
        }
    }
    
    lazy var dateLabel: NMLabel = {
        let view = NMLabel()
        view.font = UIFont.systemFont(ofSize: 15, weight: .light)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var textLabel: NMLabel = {
        let view = NMLabel()
        view.lineBreakMode = .byWordWrapping
        view.numberOfLines = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var imageView: NMImageView = {
        let view = NMImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
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
        let safeGuide = contentView.safeAreaLayoutGuide
        
        contentView.addSubview(dateLabel)
        dateLabel.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor, constant: 10).isActive = true
        dateLabel.topAnchor.constraint(equalTo: safeGuide.topAnchor, constant: 10).isActive = true
        
        contentView.addSubview(imageView)
        imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -20).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        
        contentView.addSubview(textLabel)
        textLabel.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor, constant: 10).isActive = true
        textLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -10).isActive = true
        textLabel.bottomAnchor.constraint(lessThanOrEqualTo: safeGuide.bottomAnchor, constant: -10).isActive = true

        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 2)
       
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }
    
    func bindViewModel() {
        viewModel.outputs.date
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.text
            .bind(to: textLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.image
            .filter { $0 != nil }
            .map { UIImage(data: $0!) }
            .bind(to: imageView.rx.image)
            .disposed(by: self.disposeBag)
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.15) {
            self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            self.contentView.backgroundColor = self.contentView.backgroundColor?.withAlphaComponent(0.8)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.15) {
            self.transform = .identity
            self.contentView.backgroundColor = self.contentView.backgroundColor?.withAlphaComponent(1)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.15) {
            self.transform = .identity
            self.contentView.backgroundColor = self.contentView.backgroundColor?.withAlphaComponent(1)
        }
    }
    
}

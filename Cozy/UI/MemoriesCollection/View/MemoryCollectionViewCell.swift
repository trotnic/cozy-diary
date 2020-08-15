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
    
    lazy var textLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(textLabel)
        let safeGuide = contentView.safeAreaLayoutGuide
        textLabel.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor).isActive = true
        
    }
    
    
}

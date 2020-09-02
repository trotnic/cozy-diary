//
//  MemorySearchFilterCollectionCell.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/2/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit


class MemorySearchFilterTagCell: NMCollectionViewCell {
    static let reuseIdentifier = "MemorySearchFilterTagCell"
    
    lazy var valueLabel: NMLabel = {
        let view = NMLabel()
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
    
    private func setupLabel() {
        contentView.addSubview(valueLabel)
        
        valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}

class MemorySearchFilterDateCell: NMCollectionViewCell {
    static let reuseIdentifier = "MemorySearchFilterDateCell"
    
    lazy var valueLabel: NMLabel = {
        let view = NMLabel()
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
    
    private func setupLabel() {
        contentView.addSubview(valueLabel)
        
        valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    
}

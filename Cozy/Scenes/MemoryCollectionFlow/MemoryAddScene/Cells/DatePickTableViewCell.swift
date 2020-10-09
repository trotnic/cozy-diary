//
//  DatePickTableViewCell.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 10/9/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit

class DatePickTableViewCell: NMTableViewCell {

    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.tintColor = .orange
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    static let reuseIdentifier = "DatePickTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupDatePicker()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDatePicker() {
        contentView.addSubview(datePicker)
        
        datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        datePicker.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    

}

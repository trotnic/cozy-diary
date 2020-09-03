//
//  MonthModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/3/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation


class MonthModel {
    var isSelected: Bool
    let value: Months
    
    init(value: Months, isSelected: Bool = false) {
        self.value = value
        self.isSelected = isSelected
    }
}

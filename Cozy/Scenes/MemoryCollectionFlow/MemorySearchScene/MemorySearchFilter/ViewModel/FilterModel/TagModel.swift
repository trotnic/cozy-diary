//
//  TagModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/3/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation


class TagModel {
    var isSelected: Bool
    let value: String
    
    init(value: String, isSelected: Bool = false) {
        self.value = value
        self.isSelected = isSelected
    }
}

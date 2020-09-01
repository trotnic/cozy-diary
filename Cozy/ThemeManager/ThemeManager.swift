//
//  ThemeManager.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/31/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class ThemeManager {
    static let shared = ThemeManager()
    let currentTheme = BehaviorRelay<Theme>(value: LightTheme())
}

protocol Theme {
    var themeColor: BehaviorRelay<UIColor> { get } // bars
    var backgroundColor: BehaviorRelay<UIColor> { get } // background
    var tintColor: BehaviorRelay<UIColor> { get } // interactive elements
    var borderColor: BehaviorRelay<UIColor> { get } // borders\dividers
    var textColor: BehaviorRelay<UIColor> { get } // text
}

class LightTheme: Theme {
    let themeColor = BehaviorRelay<UIColor>(value: UIColor(hex: "CCC5B9")!)
    let backgroundColor = BehaviorRelay<UIColor>(value: UIColor(hex: "FFFCF2")!)
    let tintColor = BehaviorRelay<UIColor>(value: UIColor(hex: "EB5E28")!)
    let borderColor = BehaviorRelay<UIColor>(value: UIColor(hex: "403D39")!)
    let textColor = BehaviorRelay<UIColor>(value: UIColor(hex: "252422")!)
    
}

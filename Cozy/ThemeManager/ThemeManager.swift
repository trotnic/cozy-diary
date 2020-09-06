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
import Alertift

enum Themes {
    case light
    case dark
}

class ThemeManager {
    
    static let shared = ThemeManager()
    
    private let disposeBag = DisposeBag()
    
    private init() {
        
        
        currentTheme.bind { (color) in
            color.backgroundColor.bind { (color) in
                Alertift.Alert.backgroundColor = color
                
                Alertift.ActionSheet.backgroundColor = color
            }
            .disposed(by: self.disposeBag)
            
            color.textColor.bind { (color) in
                Alertift.Alert.titleTextColor = color
                Alertift.Alert.messageTextColor = color
                
                Alertift.ActionSheet.titleTextColor = color
                Alertift.ActionSheet.messageTextColor = color
            }
            .disposed(by: self.disposeBag)
            
            color.tintColor.bind { (color) in
                Alertift.Alert.buttonTextColor = color
                
                Alertift.ActionSheet.buttonTextColor = color
            }
            .disposed(by: self.disposeBag)
        }
        .disposed(by: self.disposeBag)
    }
    
    func provideWithInterfaceStyle(_ style: UIUserInterfaceStyle) {
        if style == .dark {
            currentTheme.accept(DarkTheme())
        } else {
            currentTheme.accept(LightTheme())
        }
    }
    
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

// background -> text
// tint -> tint
// border -> theme
// text -> background
// theme -> border

class DarkTheme: Theme {
    let themeColor = BehaviorRelay<UIColor>(value: UIColor(hex: "403D39")!)
    let backgroundColor = BehaviorRelay<UIColor>(value: UIColor(hex: "252422")!)
    let tintColor = BehaviorRelay<UIColor>(value: UIColor(hex: "EB5E28")!)
    let borderColor = BehaviorRelay<UIColor>(value: UIColor(hex: "CCC5B9")!)
    let textColor = BehaviorRelay<UIColor>(value: UIColor(hex: "FFFCF2")!)
}

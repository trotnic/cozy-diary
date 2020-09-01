//
//  NMSearchController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/1/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NMSearchController: UISearchController {

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        searchBar.isTranslucent = false
//        hidesNavigationBarDuringPresentation = false
//        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        bindTheme()
    }
}

extension NMSearchController {
    func bindTheme() {
        
        let theme = ThemeManager.shared.currentTheme
        
        theme.bind { [weak self] (theme) in
            guard let self = self else { return }
            
            theme.themeColor
                .bind(to: self.searchBar.rx.backgroundColor)
                .disposed(by: self.disposeBag)
            
            theme.themeColor
            .bind(onNext: { (color) in
                self.searchBar.setBackgroundImage(UIImage(color: color, size: self.searchBar.bounds.size), for: .any, barMetrics: .default)
                self.searchBar.barTintColor = color
            })
            .disposed(by: self.disposeBag)
        }
        .disposed(by: disposeBag)
        
        
    }
}

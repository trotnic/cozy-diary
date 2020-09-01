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
//        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        bindTheme()
    }
}

extension NMSearchController {
    func bindTheme() {
        
        let theme = ThemeManager.shared.currentTheme
        
        theme.bind { [weak self] (theme) in
            guard let self = self else { return }
            theme.themeColor.bind { (color) in
                self.searchBar.backgroundColor = color
            }
            .disposed(by: self.disposeBag)
        }
        .disposed(by: disposeBag)
    }
}

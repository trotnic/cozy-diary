//
//  NMAlertController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/1/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NMAlertController: UIAlertController {

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindTheme()
    }
}

extension NMAlertController {
    func bindTheme() {
        let theme = ThemeManager.shared.currentTheme
        
        theme.bind { [weak self] (theme) in
            guard let self = self else { return }
            
            theme.tintColor.bind { (color) in
                self.view.tintColor = color
            }
            .disposed(by: self.disposeBag)
            
            if let firstSubview = self.view.subviews.first, let alertContentView = firstSubview.subviews.first {
                for view in alertContentView.subviews {
                    theme.backgroundColor.bind(to: view.rx.backgroundColor).disposed(by: self.disposeBag)
                }
            }
        }
        .disposed(by: disposeBag)
    }
}

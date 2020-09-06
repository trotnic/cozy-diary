//
//  NMMainThemeView.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NMMainThemeView: UIView {

    private let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        bindTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
        
}

extension NMMainThemeView {
    func bindTheme() {
        let theme = ThemeManager.shared.currentTheme
        
        theme.bind { [weak self] (theme) in
                guard let self = self else { return }
                theme.themeColor.bind(to: self.rx.backgroundColor).disposed(by: self.disposeBag)
            }
        .disposed(by: disposeBag)
    }
}

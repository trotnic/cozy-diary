//
//  NMTextView.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/30/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NMTextView: UITextView {

    private let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        bindTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NMTextView {
    func bindTheme() {
        let theme = ThemeManager.shared.currentTheme
        
        theme.bind { [weak self] (theme) in
            guard let self = self else { return }
            theme.backgroundColor.bind(to: self.rx.backgroundColor).disposed(by: self.disposeBag)
//            theme.mainColor.bind(to: self.rx.backgroundColor).disposed(by: self.disposeBag)
            theme.tintColor.bind { (color) in
                self.tintColor = color
            }
            .disposed(by: self.disposeBag)
        }
        .disposed(by: self.disposeBag)
        
    }
}

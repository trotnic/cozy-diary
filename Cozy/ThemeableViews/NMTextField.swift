//
//  NMTextField.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/1/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NMTextField: UITextField {

    private let disposeBag = DisposeBag()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension NMTextField {
    func bindTheme() {
        let theme = ThemeManager.shared.currentTheme
        
        theme.bind { [weak self] (theme) in
            guard let self = self else { return }
            theme.backgroundColor.bind(to: self.rx.backgroundColor).disposed(by: self.disposeBag)
            
            theme.textColor.bind { (color) in
                self.textColor = color
            }
            .disposed(by: self.disposeBag)
        }
        .disposed(by: disposeBag)
    }
}

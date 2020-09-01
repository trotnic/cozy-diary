//
//  NMImageView.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/30/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NMImageView: UIImageView {

    private let disposeBag = DisposeBag()
    
    convenience init() {
        self.init(frame: .zero)        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bindTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NMImageView {
    func bindTheme() {
//        let theme = ThemeManager.shared.currentTheme
        
    }
    
}

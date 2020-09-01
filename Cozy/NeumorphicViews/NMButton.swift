//
//  NMButton.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/30/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NMButton: UIButton {
    
    let rxTintColor = BehaviorRelay<UIColor>(value: .white)
    
    private let disposeBag = DisposeBag()
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                tintColor = rxTintColor.value.withAlphaComponent(0.7)
            } else {
                tintColor = rxTintColor.value
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bindTheme()
        
        rxTintColor.bind { [weak self] (color) in
            self?.tintColor = color
        }
        .disposed(by: disposeBag)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NMButton {
    func bindTheme() {
        let theme = ThemeManager.shared.currentTheme
        
        theme.bind { [weak self] (theme) in
            guard let self = self else { return }
            theme.tintColor.bind(to: self.rxTintColor).disposed(by: self.disposeBag)
        }
        .disposed(by: self.disposeBag)
    }
}

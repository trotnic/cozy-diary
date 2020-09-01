//
//  NMCanvasView.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/1/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import PencilKit
import RxSwift

class NMCanvasView: PKCanvasView {

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

extension NMCanvasView {
    func bindTheme() {
        let theme = ThemeManager.shared.currentTheme
        
        theme.bind { [weak self] (theme) in
            guard let self = self else { return }
            
            theme.backgroundColor
                .bind(to: self.rx.backgroundColor)
                .disposed(by: self.disposeBag)
        }
        .disposed(by: disposeBag)
    }
}

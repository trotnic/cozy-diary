//
//  NMCollectionView.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/1/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NMCollectionView: UICollectionView {

    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        bindTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NMCollectionView {
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

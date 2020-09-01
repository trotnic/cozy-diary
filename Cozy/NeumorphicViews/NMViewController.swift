//
//  BaseViewController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NMViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindTheme()
    }
    
    func stubSwipeToRight() {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
    }
    
    func stubSwipeToLeft() {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .left
        view.addGestureRecognizer(swipe)
    }
}

extension NMViewController {
    func bindTheme() {
        let theme = ThemeManager.shared.currentTheme
        theme.bind { [weak self] (theme) in
            guard let self = self else { return }
            theme.backgroundColor.bind(to: self.view.rx.backgroundColor).disposed(by: self.disposeBag)
            
            theme.themeColor.bind { (color) in
                self.navigationController?.navigationBar.backgroundColor = color
            }
            .disposed(by: self.disposeBag)
//            theme.mainColor.bind(to: self.view.rx.backgroundColor).disposed(by: self.disposeBag)
            
//            theme.textColor.bind { (color) in
//
//                if let item = self.navigationItem.leftBarButtonItem {
//                    item.tintColor = color
//                }
////                self.navigationItem.backBarButtonItem?.tintColor = color
//            }
//            .disposed(by: self.disposeBag)
        }
        .disposed(by: disposeBag)
    }
}

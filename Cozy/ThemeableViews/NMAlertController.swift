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
import Alertift



class NMAlertController: UIAlertController {

    private let disposeBag = DisposeBag()
    
    let textFieldColor = BehaviorRelay<UIColor>(value: .white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindTheme()
    }
    
    override func addTextField(configurationHandler: ((UITextField) -> Void)? = nil) {
        let theme = ThemeManager.shared.currentTheme
        super.addTextField { (textField) in
            theme.bind { [weak self] (theme) in
                
                
                guard let self = self, let child = self.children.last else { return }
                
                
                
//                textField.borderStyle = .none
//                textField.insets
//                textField.borderStyle = .roundedRect
//                textField.layer.borderWidth = 0
//                textField.background = UIImage()
                theme.backgroundColor.bind { (color) in
                    child.view.subviews.forEach { $0.backgroundColor = color }
//                    textField.subviews.forEach { $0.backgroundColor = color }
//                    textField.textInputView.backgroundColor = color
//                    textField.backgroundColor = color
//                    textField.textInputView.inputView?.backgroundColor = color
                }
                .disposed(by: self.disposeBag)
//                theme.backgroundColor.bind(to: textField.rx.backgroundColor).disposed(by: self.disposeBag)
                theme.tintColor.bind { (color) in
                    textField.tintColor = color
                }
                .disposed(by: self.disposeBag)
                theme.textColor.bind { (color) in
                    textField.textColor = color
                }
                .disposed(by: self.disposeBag)
            }
            .disposed(by: self.disposeBag)
        }
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

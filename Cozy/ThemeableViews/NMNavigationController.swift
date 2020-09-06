//
//  NMNavigationController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/30/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NMNavigationController: UINavigationController {
    
    var dividerLeadingConstraint: NSLayoutConstraint!
    var dividerTrailingConstraint: NSLayoutConstraint!
    
    let dividerColor = BehaviorRelay<UIColor>(value: .black)
    let titleColor = BehaviorRelay<UIColor>(value: .black)
    
    private let disposeBag = DisposeBag()
    
    lazy var dividerView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        self.dividerColor
            .bind(to: view.rx.backgroundColor)
            .disposed(by: self.disposeBag)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupDividerView()
        bindTheme()
    }
    
    private func setupNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        
        titleColor.bind { [weak self] (color) in
            guard let self = self else { return }
            self.navigationBar.titleTextAttributes = [.foregroundColor : color]
        }
        .disposed(by: self.disposeBag)
    }
    
    private func setupDividerView() {
        navigationBar.addSubview(dividerView)
        
        dividerLeadingConstraint = dividerView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor)
        dividerTrailingConstraint = dividerView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor)
        dividerView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
        dividerLeadingConstraint.isActive = true
        dividerTrailingConstraint.isActive = true

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        ThemeManager.shared.provideWithInterfaceStyle(traitCollection.userInterfaceStyle)
    }
}

extension NMNavigationController {
    func bindTheme() {
        
        let theme = ThemeManager.shared.currentTheme
        
        theme.subscribe(onNext: { [weak self] (theme) in
            guard let self = self else { return }
            
            theme.borderColor
                .bind(to: self.dividerColor)
                .disposed(by: self.disposeBag)            
            
            theme.textColor
                .bind(to: self.titleColor)
                .disposed(by: self.disposeBag)
            
            theme.themeColor
                .bind(onNext: { (color) in
                    self.navigationBar.setBackgroundImage(UIImage(color: color, size: self.navigationBar.bounds.size), for: .default)
                })
                .disposed(by: self.disposeBag)
                        
            theme.tintColor
                .bind { (color) in
                    self.navigationBar.tintColor = color
                }
                .disposed(by: self.disposeBag)
            
            theme.backgroundColor
                .bind(to: self.view.rx.backgroundColor)
                .disposed(by: self.disposeBag)
        })
        .disposed(by: self.disposeBag)
        
    }
}

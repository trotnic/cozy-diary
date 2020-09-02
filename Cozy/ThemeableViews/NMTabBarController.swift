//
//  NMTabBarController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/31/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NMTabBarController: UITabBarController {

    var dividerLeadingConstraint: NSLayoutConstraint!
    var dividerTrailingConstraint: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    
    lazy var dividerView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        
        tabBar.tintColor = .black
        
        setupDividerView()
        bindTheme()
    }
    
    private func setupDividerView() {
        tabBar.addSubview(dividerView)

        dividerLeadingConstraint = dividerView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor)
        dividerTrailingConstraint = dividerView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor)

        dividerLeadingConstraint.isActive = true
        dividerTrailingConstraint.isActive = true
    }
}

extension NMTabBarController {
    func bindTheme() {
        let theme = ThemeManager.shared.currentTheme
        
        theme.bind { [weak self] (theme) in
            guard let self = self else { return }
            theme.tintColor.bind { (color) in
                self.tabBar.tintColor = color
            }
            .disposed(by: self.disposeBag)
            
            theme.borderColor.bind { (color) in
                self.tabBar.unselectedItemTintColor = color.withAlphaComponent(0.7)
            }
            .disposed(by: self.disposeBag)
            
            theme.themeColor
                .bind(to: self.tabBar.rx.backgroundColor)
                .disposed(by: self.disposeBag)
            
            theme.borderColor
                .bind(to: self.dividerView.rx.backgroundColor)
                .disposed(by: self.disposeBag)
            
        }
        .disposed(by: disposeBag)
    }
}

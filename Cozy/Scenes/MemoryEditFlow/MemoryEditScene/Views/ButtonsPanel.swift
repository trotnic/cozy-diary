//
//  ButtonsPanel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/20/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ButtonsPanel: UIView {

    let buttonSize = BehaviorRelay<CGFloat>(value: 46)
    let panelBackgroundColor = BehaviorRelay<UIColor>(value: .white)
    
    var buttons: BehaviorRelay<[UIButton]> = .init(value: [])
    private let disposeBag = DisposeBag()
    
    lazy var expandedStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal

        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buttonSize.map { $0/2 }.bind { [weak self] (radius) in
            self?.layer.cornerRadius = radius
        }
        .disposed(by: self.disposeBag)
        
        panelBackgroundColor.bind(to: self.rx.backgroundColor).disposed(by: self.disposeBag)
        
        addSubview(expandedStackView)
        setConstraints()
        bindTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setConstraints() {
        
        
        buttons
            .bind { (buttons) in
                buttons.forEach { [weak self] (button) in
                    if let self = self {
                        self.buttonSize.bind { (size) in
                            button.layer.cornerRadius = size / 2
                            button.heightAnchor.constraint(equalToConstant: size).isActive = true
                            button.widthAnchor.constraint(equalToConstant: size).isActive = true
                        }
                        .disposed(by: self.disposeBag)
                        
                        self.expandedStackView.addArrangedSubview(button)
                    }
                }
            }
            .disposed(by: disposeBag)
      
        expandedStackView.translatesAutoresizingMaskIntoConstraints = false
        expandedStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        expandedStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: expandedStackView.heightAnchor).isActive = true
        widthAnchor.constraint(equalTo: expandedStackView.widthAnchor).isActive = true
    }
    
}

extension ButtonsPanel {
    func bindTheme() {
        let theme = ThemeManager.shared.currentTheme
        
        theme.bind { [weak self] (theme) in
            guard let self = self else { return }
            theme
                .themeColor
                .bind(to: self.panelBackgroundColor)
                .disposed(by: self.disposeBag)
        }
        .disposed(by: self.disposeBag)
    }
}

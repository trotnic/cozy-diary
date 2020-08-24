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

    var buttonSize: CGFloat = 46
    var shadowOpacity: Float = 0.7
    
    var buttons: BehaviorRelay<[UIButton]> = .init(value: [])
    private let disposeBag = DisposeBag()
    
    lazy var expandedStackView: UIStackView = {
      let stackView = UIStackView()
      stackView.axis = .horizontal
      
      return stackView
    }()

    override init(frame: CGRect) {
      super.init(frame: frame)
//      backgroundColor = UIColor(red: 81/255, green: 166/255, blue: 219/255, alpha: 1)
      layer.cornerRadius = buttonSize / 2
      layer.shadowColor = UIColor.lightGray.cgColor
      layer.shadowOpacity = shadowOpacity
      layer.shadowOffset = .zero
      addSubview(expandedStackView)
      setConstraints()
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    private func setConstraints() {
        buttons.bind { [weak self] (userButtons) in
            if let strongSelf = self {
                userButtons.forEach {
                    $0.layer.cornerRadius = strongSelf.buttonSize / 2
                    $0.heightAnchor.constraint(equalToConstant: strongSelf.buttonSize).isActive = true
                    $0.widthAnchor.constraint(equalToConstant: strongSelf.buttonSize).isActive = true
                    strongSelf.expandedStackView.addArrangedSubview($0)
                }
            }
        }.disposed(by: disposeBag)
      
      expandedStackView.translatesAutoresizingMaskIntoConstraints = false
      expandedStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
      expandedStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
      
      translatesAutoresizingMaskIntoConstraints = false
      heightAnchor.constraint(equalTo: expandedStackView.heightAnchor).isActive = true
      widthAnchor.constraint(equalTo: expandedStackView.widthAnchor).isActive = true
    }
    
}

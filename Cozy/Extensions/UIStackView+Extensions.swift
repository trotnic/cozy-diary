//
//  UIStackView+Extensions.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/25/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit


extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}

//
//  UIView+Extensions.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/25/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit


extension UIView {
    func childFirstResponder() -> UIView? {
        if self.isFirstResponder { return self }
        for subview in subviews {
            let firstResponder = subview.childFirstResponder()
            if firstResponder != nil {
                return firstResponder
            }
        }
        return nil
    }
}

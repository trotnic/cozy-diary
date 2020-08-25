//
//  UIFont+Extensions.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/25/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit


extension UIFont {
        
    // MARK: Bold
    
    func bold() -> UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.insert([.traitBold])
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return .init(descriptor: descriptor, size: 0)
        }
        return self
    }
    
    func undoBold() -> UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.remove([.traitBold])
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return .init(descriptor: descriptor, size: 0)
        }
        return self
    }
    
    func isBold() -> Bool {
        fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    // MARK: Italic
    
    func italic() -> UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.insert([.traitItalic])
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return .init(descriptor: descriptor, size: 0)
        }
        return self
    }
    
    func undoItalic() -> UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.remove(.traitItalic)
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return .init(descriptor: descriptor, size: 0)
        }
        return self
    }
    
    func isItalic() -> Bool {
        fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
}

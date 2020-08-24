//
//  Helpers.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/16/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import UIKit


protocol MemorizableView: UIView {
    func becomeFirstResponder()
}


struct ImageMeta {
    let imageUrl: URL?
    let originalImage: Data?
    let editedImage: Data?
}

class ImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var completion: ((ImageMeta) -> ())?
    
    lazy var imagePickerController: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.delegate = self
        return controller
    }()
    
    func prepareCamera(_ presenting: @escaping (UIImagePickerController) -> (), completion: @escaping (ImageMeta) -> ()) {
        imagePickerController.sourceType = .camera
        presenting(imagePickerController)
        self.completion = completion
    }
    
    func prepareGallery(_ presenting: @escaping (UIImagePickerController) -> (), completion: @escaping (ImageMeta) -> ()) {
        imagePickerController.sourceType = .photoLibrary
        presenting(imagePickerController)
        self.completion = completion
    }
    
    // TODO: Unsplash-way to pick photo
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let originalImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)?.jpegData(compressionQuality: 1)
        let editedImage = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage)?.jpegData(compressionQuality: 1)
        let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL
        let imageMeta = ImageMeta(imageUrl: imageUrl, originalImage: originalImage, editedImage: editedImage)
        completion?(imageMeta)
    }
}

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

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

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

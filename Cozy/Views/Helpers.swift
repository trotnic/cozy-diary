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
        let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL
        let imageMeta = ImageMeta(imageUrl: imageUrl, originalImage: originalImage)
        completion?(imageMeta)
    }
}


//
//  ImageDetailCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/19/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import UIKit

class ImageDetailCoordinator {
    
    private let controller: UIViewController
    private let image: Data
    
    init(_ presentationController: UIViewController, image: Data) {
        controller = presentationController
        self.image = image
    }
    
    func start() {
        
        let viewModel = ImageDetailViewModel(image: image)
        let vc = ImageDetailViewController(viewModel)
        controller.present(vc, animated: true)
        
    }
    
}

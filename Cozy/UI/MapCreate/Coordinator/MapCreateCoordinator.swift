//
//  MapCreateCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/24/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


class MapCreateCoordinator: Coordinator {
    
    var viewController: MapCreateViewController!
    let presentingController: UIViewController
    
    
    init(_ presentingController: UIViewController) {
        self.presentingController = presentingController
    }
    
    func start() {
        let viewModel = MapCreateViewModel()
        viewController = .init(viewModel: viewModel)
        presentingController.present(viewController, animated: true)
    }
}

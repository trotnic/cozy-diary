//
//  VoiceRecordCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/5/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit


class VoiceRecordCoordinator: Coordinator {
    
    var viewController: VoiceRecordController!
    let presentingController: UIViewController
    
    private let manager: VoiceChunkManagerType
    
    // MARK: Init
    init(presentingController: UIViewController, manager: VoiceChunkManagerType) {
        self.presentingController = presentingController
        self.manager = manager
    }
    
    func start() {
        let viewModel = VoiceRecordViewModel(manager: manager)
        viewController = .init(viewModel: viewModel)
        
        let wrapController = NMNavigationController(rootViewController: viewController)
        
        wrapController.modalPresentationStyle = .fullScreen
        
        presentingController.present(wrapController, animated: true)
    }
    
    // MARK: Private methods
}

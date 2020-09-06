//
//  CoordinatorType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation


protocol Coordinator: class {
    func start()
}

protocol ParentCoordinator: Coordinator {
    var childCoordinators: [Coordinator] { get }
}

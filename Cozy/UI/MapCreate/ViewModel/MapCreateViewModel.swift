//
//  MapCreateViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/24/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation


protocol MapCreateViewModelOutput {
    
}

protocol MapCreateViewModelInput {
    
}

protocol MapCreateViewModelType {
    var outputs: MapCreateViewModelOutput { get }
    var inputs: MapCreateViewModelInput { get }
}

class MapCreateViewModel: MapCreateViewModelType, MapCreateViewModelOutput, MapCreateViewModelInput {
    
    var outputs: MapCreateViewModelOutput { return self }
    var inputs: MapCreateViewModelInput { return self }
    
    // MARK: Outputs
    
    
    // MARK: Inputs
    
    
}

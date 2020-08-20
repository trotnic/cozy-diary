//
//  ImageDetailViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/19/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift


class ImageDetailViewModel {
    
    var image: BehaviorRelay<Data>
    
    init(image: Data) {
        self.image = .init(value: image)
    }
    
}

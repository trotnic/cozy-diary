//
//  ImageDataProviderType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/11/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift


protocol ImageDataProviderType {
    var image: Observable<Data> { get }
}

//
//  FakeUnsplashService.swift
//  CozyTests
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift

@testable import Cozy

class FakeUnsplashService<T: Decodable>: UnsplashServiceType {
    
    var toFetch: T!
    
    func fetch<T>(request: UnsplashRequest) -> Observable<T> where T : Decodable { .just(toFetch as! T) }
}

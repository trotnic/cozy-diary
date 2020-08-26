//
//  UnsplashPhotoCache.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/26/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift

protocol PhotoCacheType {
    func fetchPhotoFor(url: URL) -> Observable<Data>
}

class UnsplashPhotoCache: PhotoCacheType {
    
    // MARK: Private properties
    private let cache: Dictionary<URL, Data> = [:]
    
    // MARK: Init
    
    
    // MARK: Public methods
    func fetchPhotoFor(url: URL) -> Observable<Data> {
        return .create { (observer) -> Disposable in
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard error == nil else {
                    observer.onError(error!)
                    return
                }
                
                guard let data = data else {
                    observer.onError(URLError.init(.downloadDecodingFailedMidStream))
                    return
                }
                
                observer.onNext(data)
                observer.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    // MARK: Private methods
}

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
    func fetchPhotoFor(url: URL) -> Observable<UIImage>
}

class UnsplashPhotoCache: PhotoCacheType {
    
    // MARK: Private properties
    private var cache: Dictionary<URL, UIImage> = [:]
    
    // MARK: Init
    
    
    // MARK: Public methods
    func fetchPhotoFor(url: URL) -> Observable<UIImage> {
        return .create { (observer) -> Disposable in
            
            if let cached = self.cache[url] {
                observer.onNext(cached)
                observer.onCompleted()
                return Disposables.create()
            } else {
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard error == nil else {
                        observer.onError(error!)
                        return
                    }
                    
                    guard let data = data,
                        let image = UIImage(data: data) else {
                        observer.onError(URLError.init(.downloadDecodingFailedMidStream))
                        return
                    }
                    
                    self.cache[url] = image
                    
                    observer.onNext(image)
                    observer.onCompleted()
                }
                
                task.resume()
                return Disposables.create {
                    task.cancel()
                }
            }
        }
    }

    // MARK: Private methods
}

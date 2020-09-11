//
//  RemoteImageDataProvider.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/11/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import Kingfisher
import RxSwift


class RemoteImageDataProvider: ImageDataProviderType {
    
    var image: Observable<Data> { imageObserver.asObservable() }
    
    private let imageObserver = PublishSubject<Data>()
    
    init(url: URL, downloader: ImageDownloader) {
        downloader.downloadImage(with: url) { [weak self] (result) in
            switch result {
            case .success(let result):
                self?.imageObserver.onNext(result.originalData)
            case .failure(let error):
                print("ERROR: Can't load image. Message: \(error)")
            }            
        }
    }
}

//
//  UnsplashNetwork.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/26/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift


protocol URLRequestConvertible {
    func urlReqeust() -> URLRequest?
}

enum UnsplashRequest: URLRequestConvertible {
    case photos(page: Int, limit: Int)
    
    
    // MARK: Configurations
    
    var scheme: String {
        "https"
    }
    
    var host: String {
        "api.unsplash.com"
    }
    
    var endPoint: String {
        switch self {
        case .photos:
            return "/photos"
        }
    }
    
    var method: String {
        switch self {
        case .photos:
            return "GET"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case let .photos(page, limit):
            return [
                .init(name: "page", value: "\(page)"),
                .init(name: "limit", value: "\(limit)")
            ]
        }
    }
    
    func urlReqeust() -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "\(endPoint)"
        urlComponents.queryItems = queryItems
        urlComponents.queryItems?.append(.init(name: "client_id", value: "v6gYNEmZzZCBVu_aVTGmHNQduCmZwUdqjQzM_IViH7Q"))
        
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }
    
}


protocol UnsplashServiceType {
    func fetch(request: UnsplashRequest) -> Observable<[UnsplashPhoto]>
}

class UnsplashService: UnsplashServiceType {
    
    func fetch(request: UnsplashRequest) -> Observable<[UnsplashPhoto]> {
        return .create { observer -> Disposable in
            guard let request = request.urlReqeust() else {
                observer.onError(URLError(.badURL))
                return Disposables.create()
            }
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    observer.onError(error!)
                    return
                }
                
                guard let data = data else {
                    observer.onError(URLError(.downloadDecodingFailedMidStream))
                    return
                }
                
                guard let result = try? JSONDecoder().decode([UnsplashPhoto].self, from: data) else {
                    observer.onError(URLError(.downloadDecodingFailedToComplete))
                    return
                }
                
                observer.onNext(result)
                observer.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
            
            
        }
    }
    
}

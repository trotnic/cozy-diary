//
//  UnsplashModels.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/26/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation


struct UnsplashPhoto: Decodable {
    let id: String
    let urls: UnsplashPhotoUrls
}

struct UnsplashPhotoUrls: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct UnsplashSearch: Decodable {
    let total: Int
    let totalPages: Int
    let results: [UnsplashPhoto]
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}

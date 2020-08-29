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
    let total_pages: Int
    let results: [UnsplashPhoto]
}

//
//  Business.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation

// protocols

protocol Chunkable {
    var index: Int { get set }
}

protocol TextChunkable: Chunkable {
    var text: String { get set }
}

// structs

struct TextChunk: TextChunkable {
    var text: String
    var index: Int
}


struct Memory {
    let date: Date
}

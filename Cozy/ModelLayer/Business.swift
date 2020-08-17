//
//  Business.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
//import RxSwift


protocol Chunkable: Hashable {
    var index: Int { get set }
}

protocol TextChunkable: Chunkable {
    var text: String { get set }
}

// structs

class Memory {
    let date: Date
    var texts: Set<TextChunk>

    
    init(date: Date, texts: Set<TextChunk>) {
        self.date = date
        
        self.texts = texts
    }
//    func observableTexts() -> Array<Observable<TextChunk>> {
//        texts.map { chunk -> Observable<TextChunk> in
//            .just(chunk)
//        }
//    }
}

class TextChunk: TextChunkable {
    static func == (lhs: TextChunk, rhs: TextChunk) -> Bool {
        lhs.text == rhs.text && lhs.index == rhs.index
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(text.hashValue | index)
    }
    
    
    var text: String
    var index: Int
    
    init(text: String, index: Int) {
        self.text = text
        self.index = index
    }
    
    
    
}


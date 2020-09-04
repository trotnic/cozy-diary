//
//  Business.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
//import RxSwift


protocol Chunkable {
    var index: Int { get set }
}

protocol TextChunkable: Chunkable {
    var text: NSAttributedString { get set }
}

protocol PhotoChunkable: Chunkable {
    var photo: Data { get set }
}

protocol GraffitiChunkable: Chunkable {
    var graffiti: Data { get set }
}
// structs

final class Memory: Taggable {
    let date: Date
    private(set) var index: Int
    private(set) var texts: Array<TextChunk>
    private(set) var photos: Array<PhotoChunk>
    private(set) var graffities: Array<GraffitiChunk>
    
    var tags: Tags = []
    
    private var total: Int {
        texts.count + photos.count
    }
    
    init(
        date: Date,
        index: Int,
        texts: Array<TextChunk>,
        photos: Array<PhotoChunk>,
        graffities: Array<GraffitiChunk>,
        tags: Array<String>
    ) {
        self.date = date
        self.index = index
        self.texts = texts
        self.photos = photos
        self.graffities = graffities
        self.tags = tags.map { item -> Tag<Memory> in .init(stringLiteral: item) }
    }
    
    func insertTextChunk(_ text: String) {
        texts.append(TextChunk(text: NSAttributedString(string: text), index: index))
        index += 1
        
    }
    
    func insertPhoto(_ photo: Data) {
        photos.append(PhotoChunk(photo: photo, index: index))
        index += 1
    }
    
    func insertGraffiti(_ graffiti: Data) {
        graffities.append(GraffitiChunk(graffiti: graffiti, index: index))
        index += 1
    }
    
    func removeChunk(_ chunk: Chunkable) {
        if let index = texts.firstIndex(where: { (textChunk) -> Bool in
            textChunk.index == chunk.index
        }) {
            texts.remove(at: index)
            return
        }
        if let index = photos.firstIndex(where: { (photoChunk) -> Bool in
            photoChunk.index == chunk.index
        }) {
            photos.remove(at: index)
            return
        }
        if let index = graffities.firstIndex(where: { (graffitiChunk) -> Bool in
            graffitiChunk.index == chunk.index
        }) {
            graffities.remove(at: index)
            return
        }
        
    }
    
    var sortedChunks: Array<Chunkable> {
        (texts + photos + graffities).sorted { (t1, t2) -> Bool in
            t1.index < t2.index
        }
    }
    
    func taggedWith(term: String) -> Bool {
        tags.contains(.init(rawValue: term))
    }
    
    func contains(term: String) -> Bool {
        !texts.filter { (chunk) -> Bool in
            chunk.text.string.contains(term)
        }.isEmpty
    }
    
}

extension Memory {
    convenience init() {
        self.init(
            date: Date(),
            index: 0,
            texts: [],
            photos: [],
            graffities: [],
            tags: []
        )
    }
}


// MARK: Sub Chunks


class TextChunk: TextChunkable {
    var text: NSAttributedString
    var index: Int
    
    init(text: NSAttributedString, index: Int) {
        self.text = text
        self.index = index
    }
}

class PhotoChunk: PhotoChunkable {
    var photo: Data
    var index: Int
    
    init(photo: Data, index: Int) {
        self.photo = photo
        self.index = index
    }
}

class GraffitiChunk: GraffitiChunkable {
    var graffiti: Data
    var index: Int
    
    init(graffiti: Data, index: Int) {
        self.graffiti = graffiti
        self.index = index
    }
}


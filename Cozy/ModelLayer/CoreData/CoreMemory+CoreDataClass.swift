//
//  CoreMemory+CoreDataClass.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CoreMemory)
public class CoreMemory: NSManagedObject {

    @nonobjc public static func memoryFetchRequest() -> NSFetchRequest<CoreMemory> {
        return NSFetchRequest<CoreMemory>(entityName: "CoreMemory")
    }
    
    var selfChunk: Memory {
        Memory(
            date: date ?? Date(),
            index: Int(increment),
            texts: textChunks,
            photos: photoChunks,
            graffities: graffitiChunks,
            voices: voiceChunks,
            tags: tagsRepresentation
        )
    }
    
    var textChunks: Array<TextChunk> {
        get {
            (texts?.allObjects as? Array<CoreTextChunk>)?.map { $0.selfChunk } ?? []
        }
        set {
            texts = NSSet(array: newValue)
        }
    }
    
    var photoChunks: Array<PhotoChunk> {
        get {
            (photos?.allObjects as? Array<CorePhotoChunk>)?.map { $0.selfChunk } ?? []
        }
        set {
            photos = NSSet(array: newValue)
        }
    }
    
    var graffitiChunks: Array<GraffitiChunk> {
        get {
            (graffities?.allObjects as? Array<CoreGraffitiChunk>)?.map { $0.selfChunk } ?? []
        }
        set {
            graffities = NSSet(array: newValue)
        }
    }
    
    var voiceChunks: Array<VoiceChunk> {
        get {
            (voices?.allObjects as? Array<CoreVoiceChunk>)?.map { $0.selfChunk } ?? []
        }
        set {
            voices = NSSet(array: newValue)
        }
    }
    
    var tagsRepresentation: Array<String> {
        get {
            tags?.map { String($0) } ?? []
        }
        set {
            tags = newValue.map { NSString(string: $0) }
        }
    }
    
    func updateSelfWith(_ memory: Memory, on context: NSManagedObjectContext) {
        date = memory.date
        increment = Int64(memory.index)
        
        texts = NSSet(array: memory.texts.map {
            let textEntity = CoreTextChunk(context: context)
            textEntity.index = Int64($0.index)
            textEntity.text = $0.text
            return textEntity
        })
        
        photos = NSSet(array: memory.photos.map {
            let photoEntity = CorePhotoChunk(context: context)
            photoEntity.index = Int64($0.index)
            photoEntity.photo = $0.photo
            return photoEntity
        })
        
        graffities = NSSet(array: memory.graffities.map {
            let graffitiEntity = CoreGraffitiChunk(context: context)
            graffitiEntity.index = Int64($0.index)
            graffitiEntity.graffiti = $0.graffiti
            return graffitiEntity
        })
        
        voices = NSSet(array: memory.voices.map {
            let voiceEntity = CoreVoiceChunk(context: context)
            voiceEntity.audioUrl = $0.voiceUrl
            voiceEntity.index = Int64($0.index)
            return voiceEntity
        })
        
        tagsRepresentation = memory.tags.map { $0.rawValue }
    }
    
    static func update(_ memory: Memory) {
        let copy = memory
        let context = CoreDataManager.shared.viewContext
        let fetchRequest = NSFetchRequest<CoreMemory>(entityName: "CoreMemory")
        fetchRequest.predicate = NSPredicate(format: "date == %@", copy.date as NSDate)
        
        if let fetchResults = try? context.fetch(fetchRequest) {
            if fetchResults.count > 0 {
                let entity = fetchResults.last
                
                entity?.texts = NSSet(array: copy.texts.map {
                    let textEntity = CoreTextChunk(context: context)
                    textEntity.index = Int64($0.index)
                    textEntity.text = $0.text
                    return textEntity
                })
                
                entity?.photos = NSSet(array: copy.photos.map {
                    let photoEntity = CorePhotoChunk(context: context)
                    photoEntity.index = Int64($0.index)
                    photoEntity.photo = $0.photo
                    return photoEntity
                })
                
                entity?.graffities = NSSet(array: copy.graffities.map {
                    let graffityEntity = CoreGraffitiChunk(context: context)
                    graffityEntity.index = Int64($0.index)
                    graffityEntity.graffiti = $0.graffiti
                    return graffityEntity
                })
                
                entity?.voices = NSSet(array: copy.voices.map {
                    let voiceEntity = CoreVoiceChunk(context: context)
                    voiceEntity.index = Int64($0.index)
                    voiceEntity.audioUrl = $0.voiceUrl
                    return voiceEntity
                })
                
                entity?.tagsRepresentation = memory.tags.map { $0.rawValue }
                
                entity?.increment = Int64(copy.index)
                
                try! context.save()
            }
        }
    }
    
}

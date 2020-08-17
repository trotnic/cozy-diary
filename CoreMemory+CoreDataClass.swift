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

    var selfChunk: Memory {
        get {
            
            Memory(date: date!, texts: textChunks)
        }
    }
    
    var textChunks: Set<TextChunk> {
        get {
            Set<TextChunk>((texts?.allObjects as? Array<CoreTextChunk>)?.map { $0.selfChunk } ?? [])
        }
        set {
            texts = NSSet(array: newValue.map { $0 })
        }
    }
    
    static func update(_ memory: Memory) {
        let context = CoreDataManager.shared.viewContext
        let fetchRequest = NSFetchRequest<CoreMemory>(entityName: "CoreMemory")
        fetchRequest.predicate = NSPredicate(format: "date == %@", memory.date as NSDate)
        
        if let fetchResults = try? context.fetch(fetchRequest) {
            if fetchResults.count > 0 {
                let entity = fetchResults.last
                
                
                entity?.texts = NSSet(array: memory.texts.map {
                    
                    let textEntity = CoreTextChunk(context: context)
                    textEntity.index = Int64($0.index)
                    textEntity.text = $0.text
                    return textEntity
                    
                })
                try! context.save()
            }
        }
    }
    
}

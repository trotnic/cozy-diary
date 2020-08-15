//
//  Synchronizer.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    lazy var persistenceContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Cozy")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("KAVABANGA")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistenceContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        persistenceContainer.newBackgroundContext()
    }
    
}

class CoreDataModeller {
    
    let manager: CoreDataManager
    
    init(manager: CoreDataManager) {
        self.manager = manager
    }
    
    var memories: BehaviorSubject<[Memory]> {
        let fetchRequest = NSFetchRequest<CoreMemory>(entityName: "CoreMemory")
        fetchRequest.sortDescriptors = []
        
        do {
            let object = try! self.manager.viewContext.fetch(fetchRequest)
            return .init(value:object.map { cm -> Memory in
                
                return .init(date: cm.date!)
            })
        } catch {
            
        }
        
    }
    
    
}

class Synchronizer {
    
    static let shared = Synchronizer()
    
    
    
}

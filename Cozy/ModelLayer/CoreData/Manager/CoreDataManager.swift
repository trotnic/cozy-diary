//
//  CoreDataManager.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 10/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import CoreData


protocol CoreDataManagerType {
    var viewContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }
}

class CoreDataManager: CoreDataManagerType {
    
    static let shared = CoreDataManager()
    
    let persistenceContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Cozy")
        container.loadPersistentStores { (description, error) in
            if let error = error { fatalError("FATAL: message --- \(error.localizedDescription) ---") }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext { persistenceContainer.viewContext }
    var backgroundContext: NSManagedObjectContext { persistenceContainer.newBackgroundContext() }
}

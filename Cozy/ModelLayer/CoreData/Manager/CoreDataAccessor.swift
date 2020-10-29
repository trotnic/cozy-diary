//
//  CoreDataAccessor.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 10/29/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import CoreData


class CoreDataAccessor {
    
    private let manager: CoreDataManagerType
    
    init(manager: CoreDataManagerType) {
        self.manager = manager
    }
    
    func create(object: Memory, completion: @escaping (Result<Void, Error>) -> ()) {
        let context = manager.backgroundContext
        context.perform {
            let entity = CoreMemory(context: context)
            entity.updateSelfWith(object, on: context)
            do {
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func all(completion: @escaping (Result<Array<CoreMemory>, Error>) -> ()) {
        let context = manager.viewContext
        let request = CoreMemory.memoryFetchRequest()
        
        context.perform {
            do {
                let result = try context.fetch(request)
                completion(.success(result))
            } catch  {
                completion(.failure(error))
            }
        }
    }
    
    func query(with predicate: NSPredicate, completion: @escaping (Result<CoreMemory?, Error>) -> ()) {
        let context = manager.backgroundContext
        let request = CoreMemory.memoryFetchRequest()
        request.predicate = predicate
        
        context.perform {
            do {
                let result = try context.fetch(request).first
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func update(object: Memory, completion: @escaping (Result<Void, Error>) -> ()) {
        let context = manager.backgroundContext
        context.perform {
            let request = CoreMemory.memoryFetchRequest()
            request.predicate = .init(format: "date == %@", object.date as NSDate)
            
            do {
                if let entity = try context.fetch(request).first {
                    entity.updateSelfWith(object, on: context)
                }
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func delete(object: Memory, completion: @escaping (Result<Void, Error>) -> ()) {
        let context = manager.backgroundContext
        context.perform {
            let request = CoreMemory.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
            request.predicate = .init(format: "date == %@", object.date as NSDate)
            let batchRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(batchRequest)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

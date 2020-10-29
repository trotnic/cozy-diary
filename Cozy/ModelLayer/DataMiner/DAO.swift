//
//  DAO.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 10/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import CoreData

//protocol Storable {
//    associatedtype T
//    func updateSelfWith(item: T, on context: NSManagedObjectContext)
//    func converted() -> T
//}
//
//protocol DAO {
//    associatedtype P
//    associatedtype B: Storable where B.T == P
//}
//
//protocol StorageContext {
//    associatedtype Stored: Storable where Stored.T == Persisted
//    associatedtype Persisted
//
//    func getAll(completion: (Array<Persisted>?) -> ()) throws
//    func save() throws
//    func update() throws
//    func delete() throws
//}
//
//class CoreMemoryStorage: StorageContext {
//    typealias Stored = CoreMemory
//    typealias Persisted = Memory
//
//    private let manager: CoreDataManagerType
//
//    init(manager: CoreDataManagerType) {
//        self.manager = manager
//    }
//
//    func getAll(completion: (Array<Persisted>?) -> ()) throws {
//        let context = manager.backgroundContext
//
//        let request = CoreMemory.memoryFetchRequest()
//
//    }
//
//    func save() throws {
//
//    }
//
//    func update() throws {
//
//    }
//
//    func delete() throws {
//
//    }
//}

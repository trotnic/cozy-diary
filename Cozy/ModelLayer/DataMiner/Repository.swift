//
//  Repository.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/18/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import CoreData


protocol RepositoryType {
    associatedtype T
    
    func query(with predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> Observable<[T]>
    func save(entity: T) -> Observable<Void>
    func remove(entity: T) -> Observable<Void>
}

final class Repository<T: NSManagedObject>: RepositoryType {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func query(with predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> Observable<[T]> {
        .just([])
    }
    
    func save(entity: T) -> Observable<Void> {
        .just(())
    }
    
    func remove(entity: T) -> Observable<Void> {
        .just(())
    }
}

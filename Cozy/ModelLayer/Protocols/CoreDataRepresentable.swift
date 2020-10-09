//
//  CoreDataRepresentable.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/19/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import CoreData


protocol CoreDataRepresentable {
    associatedtype CoreDataType
    
    func update(entity: CoreDataType)
    func sync(in context: NSManagedObjectContext) -> Observable<CoreDataType>
}

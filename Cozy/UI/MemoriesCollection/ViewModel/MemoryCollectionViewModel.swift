//
//  MemoryCollectionViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreData

class MemoryCollectionViewModel: MemoryCollectionViewModelProtocol {
    
    var memories: BehaviorSubject<[Memory]> {
        return CoreDataModeller(manager: CoreDataManager.shared).memories
    }
    
}

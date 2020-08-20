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
import RxCocoa

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let persistenceContainer: NSPersistentContainer = {
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

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    var isTodayRemembered: Bool {
        UserDefaults.standard.bool(forKey: "")
    }
    
}

class CoreDataModeller {
    
    let manager: CoreDataManager
    
    init(manager: CoreDataManager) {
        self.manager = manager
    }
    
    func fetchRelevantOrCreate() -> Memory {
        guard let memory = relevantMemory() else {
            return createNewOne()
        }
        return memory
    }
    
    func relevantMemory() -> Memory? {
        let context = CoreDataManager.shared.viewContext
        let fetchRequest = NSFetchRequest<CoreMemory>(entityName: "CoreMemory")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", PerfectCalendar.shared.today as NSDate, PerfectCalendar.shared.tomorrow as NSDate)
        let result = try? context.fetch(fetchRequest)
        return result?.first?.selfChunk
    }
    
    func createNewOne() -> Memory {
        let context = CoreDataManager.shared.viewContext
        let entity = CoreMemory(context: context)
        entity.date = PerfectCalendar.shared.today
        entity.increment = 1
        let textEntity = CoreTextChunk(context: context)
        textEntity.text = ""
        textEntity.index = 0
        entity.addToTexts(textEntity)
        
        do {
            try context.save()
        } catch {
            fatalError("Oh sh*t")
        }
        return entity.selfChunk
    }
    
    func fetchAllMemories() -> [Memory] {
        let context = CoreDataManager.shared.viewContext
        let fetchRequest = NSFetchRequest<CoreMemory>(entityName: "CoreMemory")
        fetchRequest.returnsObjectsAsFaults = false
        let result = try? context.fetch(fetchRequest)
        return result?.map { $0.selfChunk } ?? []
    }
}

class PerfectCalendar {
    
    static let shared = PerfectCalendar()
    
    var today: Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        return calendar.startOfDay(for: Date())
    }
    
    var tomorrow: Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        var components = DateComponents()
        components.day = 1
        return calendar.date(byAdding: components, to: calendar.startOfDay(for: Date()))!
    }
    
}

class Synchronizer {
    
    static let shared = Synchronizer()
    let relevantMemory: BehaviorRelay<Memory>
    
    private let disposeBag = DisposeBag()
    
    init() {
        let memory = CoreDataModeller(manager: CoreDataManager.shared).fetchRelevantOrCreate()
        relevantMemory = .init(value: memory)
        
        NotificationCenter.default
            .rx.notification(UIApplication.willResignActiveNotification)
            .subscribe(onNext: { notificaiton in
                
        })
        .disposed(by: disposeBag)
    }
    
    
    
}

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

protocol CoreDataManagerType {
    var viewContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }
}

class CoreDataManager: CoreDataManagerType {
    
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


// MARK: Calendar


protocol CalendarType {
    var today: Date { get }
    var tomorrow: Date { get }
}

class PerfectCalendar: CalendarType {
    
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


// MARK: Synchronizer

protocol MemoryStoreType {
    var relevantMemory: BehaviorRelay<Memory> { get }
    func fetchObservables() -> Observable<[Memory]>
    @discardableResult func addItem(_ memory: Memory) -> Bool
    @discardableResult func updateItem(_ memory: Memory) -> Bool
    @discardableResult func removeItem(_ memory: Memory) -> Bool
    
    func seekFor(_ memory: BehaviorRelay<Memory>, key: Date)
    func leaveAway(key: Date)
}

class Synchronizer: MemoryStoreType {
    
    private var blackDayBag: [Date: BehaviorRelay<Memory>] = [:]
    
    private var coreDataModels = BehaviorSubject<[CoreMemory]>(value: [])
    private let coreDataManager: CoreDataManagerType = CoreDataManager()
    
    let relevantMemory: BehaviorRelay<Memory> = .init(value: .init())
    
    private let disposeBag = DisposeBag()
    
    private let calendar: CalendarType
    
    init(calendar: CalendarType) {
        self.calendar = calendar
        coreDataModels.onNext(fetchData())
        relevantMemory.accept(fetchRelevantOrCreate())
        
        NotificationCenter.default.rx
            .notification(UIApplication.willResignActiveNotification)
            .subscribe(onNext: { [weak self] (notificaiton) in
                if let self = self {
                    let taskIdentifier = UIApplication.shared.beginBackgroundTask()
                    self.blackDayBag.values.forEach { (memory) in
                        self.updateItem(memory.value)
                    }
                    self.updateItem(self.relevantMemory.value)
                    UIApplication.shared.endBackgroundTask(taskIdentifier)
                }
            })
        .disposed(by: disposeBag)
    }
    
    private func fetchData(context: NSManagedObjectContext) -> [CoreMemory] {
        let request = CoreMemory.memoryFetchRequest()
        request.returnsDistinctResults = false
        
        do {
            return try context.fetch(request)
        } catch {
            return []
        }
    }
    
    private func fetchData() -> [CoreMemory] {
        fetchData(context: self.coreDataManager.viewContext)
    }
    
    func fetchObservables() -> Observable<[Memory]> {
        coreDataModels.map { $0.map { $0.selfChunk }}.share(replay: 1, scope: .whileConnected)
    }
    
    
    @discardableResult
    func addItem(_ memory: Memory) -> Bool {
        let context = coreDataManager.backgroundContext
        let entity = CoreMemory(context: context)
        entity.updateSelfWith(memory, on: context)
        
        do {
            try context.save()
            coreDataModels.onNext(fetchData())
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    
    @discardableResult
    func updateItem(_ memory: Memory) -> Bool {
        let context = coreDataManager.backgroundContext
        let request = CoreMemory.memoryFetchRequest()
        request.predicate = .init(format: "date == %@", memory.date as NSDate)
        
        do {
            let fetchResult = try context.fetch(request)
            if fetchResult.count == 1,
                let entity = fetchResult.last {
                entity.updateSelfWith(memory, on: context)
                try context.save()
                coreDataModels.onNext(fetchData(context: context))
                return true
            }
        } catch {
            print(error)
        }
        return false
    }
    
    
    @discardableResult
    func removeItem(_ memory: Memory) -> Bool {
        let context = coreDataManager.backgroundContext
        if let request = CoreMemory.memoryFetchRequest() as? NSFetchRequest<NSFetchRequestResult> {
            request.predicate = .init(format: "date == %@", memory.date as NSDate)
            let batchRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(batchRequest)
                coreDataModels.onNext(fetchData())
                return true
            } catch  {
                print(error)
            }
        }
        return false
    }
    
    func seekFor(_ memory: BehaviorRelay<Memory>, key: Date) {
        blackDayBag[key] = memory
    }
    
    func leaveAway(key: Date) {
        blackDayBag.removeValue(forKey: key)
    }
    
    
    private func getRelevantMemory() -> CoreMemory? {
        let context = coreDataManager.viewContext
        let request = CoreMemory.memoryFetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = .init(format: "(date >= %@) AND (date < %@)", calendar.today as NSDate, calendar.tomorrow as NSDate)
        
        let result = try? context.fetch(request)
        return result?.first
    }
    
    
    private func fetchRelevantOrCreate() -> Memory {
        guard let memory = getRelevantMemory() else {
            return createEmpty()
        }
        return memory.selfChunk
    }
    
    private func createEmpty() -> Memory {
        let context = coreDataManager.backgroundContext
        let entity = CoreMemory(context: context)
        entity.date = calendar.today
        entity.increment = 0
        do {
            try context.save()
        } catch {
            fatalError("ohm, emrorm :(")
        }
        return entity.selfChunk
    }
    
    
}

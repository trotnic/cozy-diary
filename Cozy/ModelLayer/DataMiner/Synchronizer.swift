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
    func fetchAll() -> Observable<[BehaviorRelay<Memory>]>
    func fetchBeforeNow() -> Observable<[BehaviorRelay<Memory>]>
    @discardableResult func addItem(_ memory: Memory) -> Bool
    @discardableResult func updateItem(_ memory: Memory) -> Bool
    @discardableResult func removeItem(_ memory: Memory) -> Bool
    
    func seekFor(_ memory: BehaviorRelay<Memory>, key: Date)
    func leaveAway(key: Date)
}

class Synchronizer: MemoryStoreType {
    
    private var blackDayBag: [Date: BehaviorRelay<Memory>] = [:]
    
    private var coreDataModels = BehaviorRelay<[BehaviorRelay<Memory>]>(value: [])
    private let coreDataManager: CoreDataManagerType = CoreDataManager()
    
    var relevantMemory: BehaviorRelay<Memory> {
        get {
            fetchRelevantOrCreate()
        }
    }
    
    private let disposeBag = DisposeBag()
    
    private let calendar: CalendarType
    
    init(calendar: CalendarType) {
        self.calendar = calendar
        coreDataModels.accept(fetchData().map { .init(value: $0.selfChunk) })
        
        NotificationCenter.default.rx
            .notification(UIApplication.willResignActiveNotification)
            .subscribe(onNext: { [weak self] (notificaiton) in
                if let self = self {
                    let taskIdentifier = UIApplication.shared.beginBackgroundTask()
                    self.blackDayBag.values.forEach { (memory) in
                        self.updateItem(memory.value)
                    }
                    UIApplication.shared.endBackgroundTask(taskIdentifier)
                }
            })
        .disposed(by: disposeBag)
    }
    
    private func fetchData() -> [CoreMemory] { fetchData(context: self.coreDataManager.viewContext) }
    
    private func fetchData(context: NSManagedObjectContext) -> [CoreMemory] {
        fetchData(context: context, predicate: nil)
    }
    
    private func fetchData(context: NSManagedObjectContext, predicate: NSPredicate?) -> [CoreMemory] {
        let request = CoreMemory.memoryFetchRequest()
        request.returnsDistinctResults = false
        request.predicate = predicate
        
        do {
            return try context.fetch(request)
        } catch {
            assert(false, "Fetch error, shouldn't ever happen")
            return []
        }
    }
    
    func fetchAll() -> Observable<[BehaviorRelay<Memory>]> {
        coreDataModels.asObservable()
    }
    
    func fetchBeforeNow() -> Observable<[BehaviorRelay<Memory>]> {
        coreDataModels.flatMap { (memories) -> Observable<[BehaviorRelay<Memory>]> in
            .just(memories.filter { $0.value.date < self.calendar.today })
        }
    }
    
    @discardableResult
    func addItem(_ memory: Memory) -> Bool {
        let context = coreDataManager.backgroundContext
        let entity = CoreMemory(context: context)
        entity.updateSelfWith(memory, on: context)
        
        do {
            try context.save()
            coreDataModels.accept(fetchData().map { .init(value: $0.selfChunk) })
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
                coreDataModels.accept(fetchData(context: context).map { .init(value: $0.selfChunk) })
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
                coreDataModels.accept(fetchData().map { .init(value: $0.selfChunk) })
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
        if let value = blackDayBag[key]?.value {
            updateItem(value)
        }
        blackDayBag.removeValue(forKey: key)
    }
    
    
    private func getRelevantMemory() -> BehaviorRelay<Memory>? {
        coreDataModels.value.filter { [unowned self] memory -> Bool in
            let date = memory.value.date
            return date < self.calendar.tomorrow && date >= self.calendar.today
        }.last
    }
    
    
    private func fetchRelevantOrCreate() -> BehaviorRelay<Memory> {
        guard let memory = getRelevantMemory() else {
            return createEmpty()
        }
        return memory
    }
    
    private func createEmpty() -> BehaviorRelay<Memory> {
        let context = coreDataManager.backgroundContext
        let entity = CoreMemory(context: context)
        entity.date = calendar.today
        entity.increment = 0
        do {
            try context.save()
        } catch {
            assert(false, "ohm, emrorm :(")
        }
        return .init(value: entity.selfChunk)
    }
    
    
}

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


class Synchronizer: MemoryStoreType {
    
    private var blackDayBag: [Date: BehaviorRelay<Memory>] = [:]
    
    private lazy var coreDataModels = BehaviorRelay<[BehaviorRelay<Memory>]>(value: fetchData().map { .init(value: $0.selfChunk) })
    private let coreDataManager: CoreDataManagerType = CoreDataManager()
    
    var relevantMemory: BehaviorRelay<Memory> { get { fetchRelevantOrCreate() } }    
    var allObjects: Observable<[BehaviorRelay<Memory>]> { coreDataModels.asObservable() }
//    var allObjectsBeforeNow: Observable<[BehaviorRelay<Memory>]> {
//        coreDataModels.flatMap { (memories) -> Observable<[BehaviorRelay<Memory>]> in
//            .just(memories.filter { $0.value.date < self.calendar.today })
//        }
//    }
    
    private let disposeBag = DisposeBag()
    
    private let calendar: CalendarType
    
    init(calendar: CalendarType) {
        self.calendar = calendar
        
        NotificationCenter
            .default.rx
            .notification(UIApplication.willResignActiveNotification)
            .bind(onNext: { [weak self] (notificaiton) in
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
    
    private func fetchData(context: NSManagedObjectContext) -> [CoreMemory] { fetchData(context: context, predicate: nil) }
    
    private func fetchData(context: NSManagedObjectContext, predicate: NSPredicate?) -> [CoreMemory] {
        let request = CoreMemory.memoryFetchRequest()
        request.predicate = predicate
        request.sortDescriptors = [.init(key: "date", ascending: true)]
        
        if let result = try? context.fetch(request) {
            return result
        }
        assert(false)
        return []
    }
    
    func addItem(_ memory: Memory) {
        let context = coreDataManager.backgroundContext
        let entity = CoreMemory(context: context)
        
        do {
            try entity.updateSelfWith(memory, on: context)
            coreDataModels.accept(fetchData(context: context).map { .init(value: $0.selfChunk) })
        } catch {
            print("BAD: Error message --- \(error.localizedDescription) ---")
        }
    }
    
    
    func updateItem(_ memory: Memory) {
        let context = coreDataManager.backgroundContext
        let request = CoreMemory.memoryFetchRequest()
        request.predicate = .init(format: "date == %@", memory.date as NSDate)
        
        do {
            let fetchResult = try context.fetch(request)
            if fetchResult.count >= 1,
                
                let entity = fetchResult.last {
                try entity.updateSelfWith(memory, on: context)
                coreDataModels.accept(fetchData(context: context).map { .init(value: $0.selfChunk) })
            }
        } catch {
            assert(false, "fatal: shouldn't ever happen; Error: \(error.localizedDescription)")
        }
    }
    
    
    func removeItem(_ memory: Memory) {
        let context = coreDataManager.backgroundContext
        if let request = CoreMemory.memoryFetchRequest() as? NSFetchRequest<NSFetchRequestResult> {
            request.predicate = .init(format: "date == %@", memory.date as NSDate)
            let batchRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(batchRequest)
                coreDataModels.accept(fetchData().map { .init(value: $0.selfChunk) })
            } catch  {
                assert(false, "fatal: shouldn't ever happen; Error: \(error.localizedDescription)")
            }
        }
    }
    
    func remember(_ memory: BehaviorRelay<Memory>, key: Date) {
        blackDayBag[key] = memory
    }
    
    func forget(key: Date) {
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
            assert(false, "fatal: shouldn't ever happen; Error: \(error.localizedDescription)")
        }
        return .init(value: entity.selfChunk)
    }
    
    
}

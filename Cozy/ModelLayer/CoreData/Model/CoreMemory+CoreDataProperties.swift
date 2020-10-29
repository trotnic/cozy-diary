//
//  CoreMemory+CoreDataProperties.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//
//

import Foundation
import CoreData


extension CoreMemory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreMemory> {
        return NSFetchRequest<CoreMemory>(entityName: "CoreMemory")
    }

    @NSManaged public var date: Date?
    @NSManaged public var increment: Int64
    @NSManaged public var tags: [NSString]?
    @NSManaged public var graffities: NSSet?
    @NSManaged public var photos: NSSet?
    @NSManaged public var texts: NSSet?
    @NSManaged public var voices: NSSet?

}

// MARK: Generated accessors for graffities
extension CoreMemory {

    @objc(addGraffitiesObject:)
    @NSManaged public func addToGraffities(_ value: CoreGraffitiChunk)

    @objc(removeGraffitiesObject:)
    @NSManaged public func removeFromGraffities(_ value: CoreGraffitiChunk)

    @objc(addGraffities:)
    @NSManaged public func addToGraffities(_ values: NSSet)

    @objc(removeGraffities:)
    @NSManaged public func removeFromGraffities(_ values: NSSet)

}

// MARK: Generated accessors for photos
extension CoreMemory {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: CorePhotoChunk)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: CorePhotoChunk)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}

// MARK: Generated accessors for texts
extension CoreMemory {

    @objc(addTextsObject:)
    @NSManaged public func addToTexts(_ value: CoreTextChunk)

    @objc(removeTextsObject:)
    @NSManaged public func removeFromTexts(_ value: CoreTextChunk)

    @objc(addTexts:)
    @NSManaged public func addToTexts(_ values: NSSet)

    @objc(removeTexts:)
    @NSManaged public func removeFromTexts(_ values: NSSet)

}

// MARK: Generated accessors for voices
extension CoreMemory {

    @objc(addVoicesObject:)
    @NSManaged public func addToVoices(_ value: CoreVoiceChunk)

    @objc(removeVoicesObject:)
    @NSManaged public func removeFromVoices(_ value: CoreVoiceChunk)

    @objc(addVoices:)
    @NSManaged public func addToVoices(_ values: NSSet)

    @objc(removeVoices:)
    @NSManaged public func removeFromVoices(_ values: NSSet)

}

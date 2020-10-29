//
//  CorePhotoChunk+CoreDataClass.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/17/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CorePhotoChunk)
public class CorePhotoChunk: NSManagedObject {

    var selfChunk: PhotoChunk {
        PhotoChunk(photo: photo ?? Data(), index: Int(index))
    }
    
}

//
//  CoreGraffitiChunk+CoreDataClass.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/24/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CoreGraffitiChunk)
public class CoreGraffitiChunk: NSManagedObject {

    var selfChunk: GraffitiChunk {
        GraffitiChunk(graffiti: graffiti ?? Data(), index: Int(index))
    }
    
}

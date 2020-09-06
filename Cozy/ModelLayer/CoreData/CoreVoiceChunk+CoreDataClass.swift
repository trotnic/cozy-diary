//
//  CoreVoiceChunk+CoreDataClass.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/5/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CoreVoiceChunk)
public class CoreVoiceChunk: NSManagedObject {

    var selfChunk: VoiceChunk { VoiceChunk(voiceUrl: audioUrl ?? URL(fileURLWithPath: ""), index: Int(index)) }
    
}

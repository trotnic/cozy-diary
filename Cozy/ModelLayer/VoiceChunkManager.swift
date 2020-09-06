//
//  VoiceChunkManager.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/5/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift


protocol VoiceChunkManagerType {
    var voiceFileUrl: Observable<URL> { get }
    func insertVoiceFileUrl(_ url: URL)
}

class VoiceChunkManager: VoiceChunkManagerType {
    var voiceFileUrl: Observable<URL> { fileUrlObserver.asObservable() }
    
    private let fileUrlObserver = PublishSubject<URL>()
    
    func insertVoiceFileUrl(_ url: URL) { fileUrlObserver.onNext(url) }
}

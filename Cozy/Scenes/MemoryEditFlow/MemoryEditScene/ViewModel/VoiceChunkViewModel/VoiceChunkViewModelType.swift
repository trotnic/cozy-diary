//
//  VoiceChunkViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/5/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol VoiceChunkViewModelOutput {
    var currentDurationString: Driver<String> { get }
    var totalDurationString: Driver<String> { get }
    
    var startPlaying: Driver<Void> { get }
    var pausePlaying: Driver<Void> { get }
    
    var removeItemRequest: Observable<Void> { get }
}

protocol VoiceChunkViewModelInput {
    var playButtonTap: PublishRelay<Void> { get }
    
    var removeButtonTap: PublishRelay<Void> { get }
}

protocol VoiceChunkViewModelType {
    var outputs: VoiceChunkViewModelOutput { get }
    var inputs: VoiceChunkViewModelInput { get }
}

//
//  VoiceRecordViewModelType.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/5/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol VoiceRecordViewModelOutput {
    var currentDuration: Driver<String> { get }

    var startRecording: Driver<Void> { get }
    var pauseRecording: Driver<Void> { get }
    var finishRecording: Driver<Void> { get }
    var restoreRecording: Driver<Void> { get }
    
    var presentAlert: Driver<(String, String)> { get }
}

protocol VoiceRecordViewModelInput {
    var recordButtonTap: PublishRelay<Void> { get }
    var playButtonTap: PublishRelay<Void> { get }
    var removeButtonTap: PublishRelay<Void> { get }
    var commitButtonTap: PublishRelay<Void> { get }
    
    var saveButtonTap: PublishRelay<Void> { get }
    var closeButtonTap: PublishRelay<Void> { get }
}

protocol VoiceRecordViewModelType {
    var outputs: VoiceRecordViewModelOutput { get }
    var inputs: VoiceRecordViewModelInput { get }
}

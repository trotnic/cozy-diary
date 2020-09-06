//
//  VoieChunkViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/5/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation


class VoiceChunkViewModel: VoiceChunkViewModelType, VoiceChunkViewModelOutput, VoiceChunkViewModelInput {
    
    // MARK: Outputs & Inputs
    var outputs: VoiceChunkViewModelOutput { return self }
    var inputs: VoiceChunkViewModelInput { return self }
    
    // MARK: Outputs
    var totalDurationString: Driver<String> { .just(timeFormatter.string(from: audioPlayer?.duration ?? 0) ?? "00:00") }
    var currentDurationString: Driver<String> {
        durationObserver.flatMap { [unowned self] time -> Observable<String> in
            .just(self.timeFormatter.string(from: time) ?? "00:00")
        }.asDriver(onErrorJustReturn: "00:00")
    }
    
    var startPlaying: Driver<Void> { startPlayObserver.asDriver(onErrorJustReturn: ()) }
    var pausePlaying: Driver<Void> { pausePlayObserver.asDriver(onErrorJustReturn: ()) }
    
    var removeItemRequest: Observable<Void> { removeButtonTap.asObservable() }
    
    var presentAlert: Driver<(String, String)> { alertObserver.asDriver(onErrorJustReturn: ("","")) }
    
    // MARK: Inputs
    let playButtonTap = PublishRelay<Void>()
    let removeButtonTap = PublishRelay<Void>()
    
    // MARK: Private
    private let disposeBag = DisposeBag()
    private var audioPlayer: AVAudioPlayer?
    
    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    
    private let chunk: VoiceChunk
    
    private var timeDurationObservable: Disposable?
    private let durationObserver = BehaviorRelay<TimeInterval>(value: 0)
    private var durationOffset: TimeInterval = 0
    
    private let startPlayObserver = PublishRelay<Void>()
    private let pausePlayObserver = PublishRelay<Void>()
    
    private let alertObserver = PublishRelay<(String, String)>()
    
    // MARK: Init
    init(_ chunk: VoiceChunk) {
        self.chunk = chunk
        bindPlayTap()
        bindRemoveTap()
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: self.chunk.voiceUrl)
            audioPlayer?.volume = 1
        } catch {
            alertObserver.accept(("Error with loading voice message", "Try to restart app"))
        }
    }
    
    // MARK: Private methods
    private func bindPlayTap() {
        playButtonTap
            .subscribe(onNext: { [weak self] (_) in
                if let player = self?.audioPlayer {
                    if player.isPlaying {
                        self?.pauseOperation()
                    } else {
                        self?.startOperation()
                    }
                } else {
                    self?.alertObserver.accept(("Error with playing audio", "Try to restart app"))
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindRemoveTap() {
        removeButtonTap
            .subscribe(onNext: { [weak self] in
                guard let url = self?.chunk.voiceUrl else { return }
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    self?.alertObserver.accept(("Warning", "This audio file is already absent"))
                }
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        timeDurationObservable?.dispose()
    }
}

// MARK: AVFoundation logic

extension VoiceChunkViewModel {
    
    private func startOperation() {
        timeDurationObservable = Observable<Int>
            .interval(.seconds(1), scheduler: MainScheduler.instance)
            .flatMap({ [unowned self] (time) -> Observable<Int> in
                if let player = self.audioPlayer {
                    if TimeInterval(time) >= player.duration {
                        self.restoreOperation()
                    }
                }
                return .just(time)
            })
            .map { [unowned self] time -> TimeInterval in
                TimeInterval(time) + self.durationOffset
            }
            .bind(to: durationObserver)
        
        audioPlayer?.play()
        startPlayObserver.accept(())
    }
    
    private func pauseOperation() {
        audioPlayer?.pause()
        commitDurationOffset()
        pausePlayObserver.accept(())
    }
    
    private func commitDurationOffset() {
        durationOffset = durationObserver.value
        timeDurationObservable?.dispose()
    }
    
    private func restoreOperation() {
        audioPlayer?.pause()
        durationOffset = 0
        timeDurationObservable?.dispose()
        pausePlayObserver.accept(())
    }
}

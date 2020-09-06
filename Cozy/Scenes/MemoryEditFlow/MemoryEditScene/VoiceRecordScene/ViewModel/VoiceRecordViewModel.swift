//
//  VoiceRecordViewModel.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/5/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation


class VoiceRecordViewModel: NSObject, VoiceRecordViewModelType, VoiceRecordViewModelOutput, VoiceRecordViewModelInput {
    
    // MARK: Outputs & Inputs
    var outputs: VoiceRecordViewModelOutput { return self }
    var inputs: VoiceRecordViewModelInput { return self }
    
    // MARK: Outputs
    var currentDuration: Driver<String> {
        durationObserver
        .flatMap { [weak self] time -> Observable<String> in
            .just(self?.timeFormatter.string(from: time) ?? "00:00")
        }
        .asDriver(onErrorJustReturn: "00:00")
        
    }
    var startRecording: Driver<Void> { startRecordingObserver.asDriver(onErrorJustReturn: ()) }
    var pauseRecording: Driver<Void> { pauseRecordingObserver.asDriver(onErrorJustReturn: ()) }
    var finishRecording: Driver<Void> { finishRecordingObserver.asDriver(onErrorJustReturn: ()) }
    var restoreRecording: Driver<Void> { restoreRecordingObserver.asDriver(onErrorJustReturn: ()) }
    
    // MARK: Inputs
    let recordButtonTap = PublishRelay<Void>()
    let playButtonTap = PublishRelay<Void>()
    let commitButtonTap = PublishRelay<Void>()
    let removeButtonTap = PublishRelay<Void>()
    
    let saveButtonTap = PublishRelay<Void>()
    let closeButtonTap = PublishRelay<Void>()
    
    // MARK: Private
    private let disposeBag = DisposeBag()
    
    private let durationObserver = BehaviorRelay<TimeInterval>(value: 0)
    
    private let startRecordingObserver = PublishRelay<Void>()
    private let pauseRecordingObserver = PublishRelay<Void>()
    private let finishRecordingObserver = PublishRelay<Void>()
    private let restoreRecordingObserver = PublishRelay<Void>()
    
    private var timeDurationObservable: Disposable?
    
    private lazy var recordingSession: AVAudioSession = {
        let session = AVAudioSession.sharedInstance()
        return session
    }()
    
    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    
    private var durationOffset: TimeInterval = 0
    private var currentFileUrl: URL!
    
    private let manager: VoiceChunkManagerType
    
    // MARK: Init
    init(manager: VoiceChunkManagerType) {
        self.manager = manager
        super.init()
        
        bindRecordTap()
        bindPlayTap()
        bindCommitTap()
        bindRemoveTap()
        setupRecordingSession()
        provideFileUrl()
        bindSaveTap()
        bindCloseTap()
    }
    
    // MARK: Private methods
    private func bindRecordTap() {
        recordButtonTap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                if self.audioRecorder == nil {
                    self.setupRecorder()
                }
                
                if let isRecording = self.audioRecorder?.isRecording {
                    if isRecording {
                        self.pauseOperation()
                    } else {
                        self.beginOperation()
                    }
                } else {
                    assert(false)
                }
                
            })
        .disposed(by: disposeBag)
    }
    
    private func bindPlayTap() {
        playButtonTap
            .subscribe(onNext: { [weak self] in
                guard let fileUrl = self?.currentFileUrl else { return }
                do {
                    self?.audioPlayer = try AVAudioPlayer(contentsOf: fileUrl)
                    self?.audioPlayer?.volume = 1
                    self?.audioPlayer?.play()
                } catch {
                    assert(false)
                }
            })
        .disposed(by: disposeBag)
    }
    
    private func bindCommitTap() {
        commitButtonTap
            .subscribe(onNext: { [weak self] in
                self?.finishOperation()
            })
        .disposed(by: disposeBag)
    }
    
    private func bindRemoveTap() {
        removeButtonTap
            .subscribe(onNext: { [weak self] in
                self?.restoreOperation()
            })
        .disposed(by: disposeBag)
    }
    
    private func bindSaveTap() {
        saveButtonTap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.manager.insertVoiceFileUrl(self.currentFileUrl)
                self.restoreOperation()
            })
        .disposed(by: disposeBag)
    }
    
    private func bindCloseTap() {
        closeButtonTap
            .subscribe(onNext: { [weak self] (_) in
                print("CLOSE OBSERVER NOT IMPLEMENTED IN \(self?.debugDescription ?? "")")
            })
        .disposed(by: disposeBag)
    }
    
}

// MARK: AVFoundation logic

extension VoiceRecordViewModel {
    private func setupRecordingSession() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { (isAllowed) in
                if isAllowed {
                    print("INFO: Recording allowed")
                } else {
                    assert(false, "BAD: shouldn't come here")
                }
            }
        } catch {
            assert(false, "BAD: shouldn't come here")
        }
    }
    
    private func setupRecorder() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey:  AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: currentFileUrl, settings: settings)
            audioRecorder?.delegate = self
        } catch {
            assert(false, "BAD: Shouldn't come here")
        }
    }
    
    private func provideFileUrl() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMMYY_hhmmssa"
        let fileName = "rec-\(formatter.string(from: date)).mp4"
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        self.currentFileUrl = paths[0].appendingPathComponent(fileName)
    }
    
    private func beginOperation() {
        audioRecorder?.record()

        timeDurationObservable = Observable<Int>
            .interval(.seconds(1), scheduler: MainScheduler.instance)
            .map { [unowned self] time -> TimeInterval in
                TimeInterval(time) + self.durationOffset
            }
            .bind(to: durationObserver)
        
        startRecordingObserver.accept(())
    }
    
    private func pauseOperation() {
        audioRecorder?.pause()
        commitDurationOffset()
        self.pauseRecordingObserver.accept(())
    }
    
    private func finishOperation() {
        if audioRecorder?.isRecording ?? false {
            commitDurationOffset()
        }
        
        audioRecorder?.stop()
        audioRecorder = nil
        
        finishRecordingObserver.accept(())
    }
    
    private func restoreOperation() {
        audioPlayer?.stop()
        audioRecorder?.deleteRecording()
        audioRecorder = nil
        durationOffset = 0
        timeDurationObservable?.dispose()
        durationObserver.accept(0)
        restoreRecordingObserver.accept(())
    }
    
    private func commitDurationOffset() {
        self.durationOffset = self.durationObserver.value
        self.timeDurationObservable?.dispose()
    }
}

// MARK: AVAudioRecorderDelegate

extension VoiceRecordViewModel: AVAudioRecorderDelegate {

    //    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    //        if !flag {
    //            Alertift
    //            .alert(title: "Error", message: "Can't start recording")
    //                .action(.default("Try again")) { [weak self] in
    //                    self?.beginRecording()
    //                }
    //                .action(.cancel("Cancel"))
    //            .show(on: self)
    //        }
    //    }
    
}

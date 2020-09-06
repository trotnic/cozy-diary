//
//  VoiceRecordController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/5/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alertift


class VoiceRecordController: NMViewController {

    let viewModel: VoiceRecordViewModelType
    
    private let disposeBag = DisposeBag()
    
    lazy var recordingButton: NMButton = {
        let view = NMButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var playButton: NMButton = {
        let view = NMButton()
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .regular, scale: .medium)
        view.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        view.isEnabled = false
        return view
    }()
    
    lazy var removeButton: NMButton = {
        let view = NMButton()
        let config = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular, scale: .medium)
        view.setImage(UIImage(systemName: "stop.fill", withConfiguration: config), for: .normal)
        view.isEnabled = false
        return view
    }()
    
    lazy var commitButton: NMButton = {
        let view = NMButton()
        let config = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular, scale: .medium)
        view.setImage(UIImage(systemName: "checkmark", withConfiguration: config), for: .normal)
        view.isEnabled = false
        return view
    }()
    
    lazy var buttonsStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 35
        view.distribution = .equalCentering
        return view
    }()
    
    lazy var durationLabel: NMLabel = {
        let view = NMLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var saveButton: NMButton = {
        let view = NMButton()
        view.setTitle("Save", for: .normal)
        view.isEnabled = false
        view.alpha = 0.6
        return view
    }()
    
    init(viewModel: VoiceRecordViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDurationLabel()
        setupRecordingButton()
        setupPlayButton()
        setupCommitButton()
        setupRemoveButton()
        setupButtonsStack()
        setupCloseButton()
        setupSaveButton()
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel
            .outputs
            .startRecording
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.removeButton.isEnabled = false
                self.playButton.isEnabled = false
                self.commitButton.isEnabled = true
                self.changeImageOnButton(button: self.recordingButton, with: "pause.fill")                
            })
            .disposed(by: disposeBag)
        
        viewModel
            .outputs
            .pauseRecording
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.changeImageOnButton(button: self.recordingButton, with: "mic.fill")
            })
            .disposed(by: disposeBag)
        
        viewModel
            .outputs
            .finishRecording
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.removeButton.isEnabled = true
                self.playButton.isEnabled = true
                self.recordingButton.isEnabled = false
                self.commitButton.isEnabled = false
                self.saveButton.isEnabled = true
                self.saveButton.alpha = 1
                self.changeImageOnButton(button: self.recordingButton, with: "mic.fill")
            })
            .disposed(by: disposeBag)
        
        viewModel
            .outputs
            .restoreRecording
            .drive(onNext: { [weak self] in
                self?.recordingButton.isEnabled = true
                self?.removeButton.isEnabled = false
                self?.playButton.isEnabled = false
                self?.commitButton.isEnabled = false
                self?.saveButton.isEnabled = false
                self?.saveButton.alpha = 0.6
            })
            .disposed(by: disposeBag)
        
        viewModel
            .outputs
            .currentDuration
            .drive(durationLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .outputs
            .presentAlert
            .drive(onNext: { [weak self] (title, message) in
                self?.presentAlert(title: title, message: message)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func setupRecordingButton() {
        view.addSubview(recordingButton)
        
        recordingButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        recordingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let congifuration = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular, scale: .medium)
        recordingButton.setImage(UIImage(systemName: "mic.fill", withConfiguration: congifuration), for: .normal)
        
        recordingButton.rx.tap
            .bind(to: viewModel.inputs.recordButtonTap)
            .disposed(by: disposeBag)
    }
    
    private func setupPlayButton() {
        view.addSubview(playButton)
        
        playButton
            .rx.tap
            .bind(to: viewModel.inputs.playButtonTap)
            .disposed(by: disposeBag)
    }
    
    private func setupRemoveButton() {
        view.addSubview(removeButton)
        
        removeButton
            .rx.tap
            .bind(to: viewModel.inputs.removeButtonTap)
            .disposed(by: disposeBag)
    }
    
    private func setupCommitButton() {
        view.addSubview(commitButton)
        
        commitButton
            .rx.tap
            .bind(to: viewModel.inputs.commitButtonTap)
            .disposed(by: disposeBag)
    }
    
    private func setupButtonsStack() {
        view.addSubview(buttonsStack)
        
        buttonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonsStack.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 50).isActive = true
        
        buttonsStack.addArrangedSubview(removeButton)
        buttonsStack.addArrangedSubview(playButton)
        buttonsStack.addArrangedSubview(commitButton)
    }
    
    private func setupDurationLabel() {
        view.addSubview(durationLabel)
        
        durationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        durationLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 60).isActive = true
        durationLabel.font = .systemFont(ofSize: 40, weight: .bold)
    }
    
    private func setupCloseButton() {
        let button = NMButton()
        button.setTitle("Close", for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        button
            .rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.inputs.closeButtonTap.accept(())
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupSaveButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
                
        saveButton
            .rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.inputs.saveButtonTap.accept(())
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func changeImageOnButton(button: UIButton, with systemImage: String) {
        let congifuration = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular, scale: .medium)
        button.setImage(UIImage(systemName: systemImage, withConfiguration: congifuration), for: .normal)
        UIView.animate(withDuration: 0.15) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func presentAlert(title: String, message: String) {
        Alertift
            .alert(title: title, message: message)
            .action(.default("Ok"))
            .show(on: self)
    }
    
}

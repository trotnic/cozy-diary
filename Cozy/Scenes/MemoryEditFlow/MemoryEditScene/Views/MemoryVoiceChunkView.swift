//
//  MemoryVoiceChunkView.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/5/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alertift


class VoiceChunkMemoryView: UIView {
    private let sideInsetSize: CGFloat = 5
    
    private let disposeBag = DisposeBag()
    
    var viewModel: VoiceChunkViewModelType! { didSet { bindViewModel() } }
    
    lazy var contentView: NMMainThemeView = {
        let view = NMMainThemeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var playButton: NMButton = {
        let view = NMButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var durationLabel: NMLabel = {
        let view = NMLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init() {
        super.init(frame: .zero)
    
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
        
        setupContentView()
        setupPlayButton()
        setupDurationLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel() {
        playButton
            .rx.tap
            .bind(to: viewModel.inputs.playButtonTap)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.outputs.currentDurationString.asObservable(), viewModel.outputs.totalDurationString.asObservable())
            .flatMap { (current, total) -> Observable<String> in
                .just("\(current)/\(total)")
            }
            .bind(to: durationLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .outputs
            .startPlaying
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.changeImageOn(button: self.playButton, with: "pause.circle.fill")
            })
            .disposed(by: disposeBag)
        
        viewModel
            .outputs
            .pausePlaying
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.changeImageOn(button: self.playButton, with: "play.circle.fill")
            })
            .disposed(by: disposeBag)
        
        viewModel
            .outputs
            .presentAlert
            .drive(onNext: { [weak self] (title, message) in
                self?.presentAlert(title: title, message: message)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupContentView() {
        addSubview(contentView)
        
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        layer.cornerRadius = 6
        layer.masksToBounds = true
    }
    
    private func setupPlayButton() {
        contentView.addSubview(playButton)
        
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 35, weight: .bold, scale: .large)
        playButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: .normal)
        
        playButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: sideInsetSize).isActive = true
        playButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sideInsetSize).isActive = true
        playButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -sideInsetSize).isActive = true
    }
    
    private func setupDurationLabel() {
        contentView.addSubview(durationLabel)
        
        durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sideInsetSize).isActive = true
        durationLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    private func presentAlert(title: String, message: String) {
        Alertift
            .alert(title: title, message: message)
            .action(.default("Ok"))
            .show()
    }
    
    private func changeImageOn(button: UIButton, with system: String) {
        let configuration = UIImage.SymbolConfiguration(pointSize: 35, weight: .bold, scale: .large)
        button.setImage(UIImage(systemName: system, withConfiguration: configuration), for: .normal)
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}

extension VoiceChunkMemoryView: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
         UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in self.createContextMenu() }
    }
    
    func createContextMenu() -> UIMenu {
        
        let remove = UIAction(
            title: "Remove",
            image: UIImage(systemName: "trash")?.withTintColor(.red),
            handler: { [weak self] _ in self?.viewModel.inputs.removeButtonTap.accept(()) })
        
        return UIMenu(title: "", children: [remove])
    }
}


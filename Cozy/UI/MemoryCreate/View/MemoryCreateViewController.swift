//
//  MemoryCreateViewController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift



class MemoryCreateViewController: BaseViewController {

    let viewModel: MemoryCreateViewModelType!
    
    private var buttonsPanelBottomConstraint: NSLayoutConstraint!
    private lazy var isTextPanelActive = BehaviorRelay<Bool>(value: false)
    
    init(_ viewModel: MemoryCreateViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) not implemented")
    }
    
    lazy var dateLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var contentView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var buttonsPanel: ButtonsPanel = {
        let view = ButtonsPanel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var endEditButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(systemName: "chevron.down.circle"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.isHidden = true
        return button
    }()
    
    lazy var textFormatButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(systemName: "a"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.isHidden = true
        return button
    }()
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Current item"
        
        view.backgroundColor = .white
        
        setupScrollView()
        bindViewModel()
        setupPanel()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        isTextPanelActive.accept(isTextPanelActive.value)
    }
    
    func bindViewModel() {

        viewModel.outputs.items.map { $0.map { (item) -> UIView in
            switch item {
            case let .PhotoItem(viewModel):
                let view = PhotoChunkMemoryView()
                view.viewModel = viewModel
                return view
            case let .TextItem(viewModel):
                let view = TextChunkMemoryView()
                view.viewModel = viewModel
                return view
            case let .GraffitiItem(viewModel):
                let view = GraffitiChunkMemoryView()
                view.viewModel = viewModel
                return view
            }
            }}.subscribe(onNext: { [weak self] (views) in
                self?.contentView.removeAllArrangedSubviews()
                views.forEach { self?.contentView.addArrangedSubview($0) }
        }).disposed(by: disposeBag)
        
        let tapGesture = UITapGestureRecognizer()
        scrollView.addGestureRecognizer(tapGesture)
        tapGesture
            .rx.event
            .observeOn(MainScheduler.asyncInstance)
            .bind { [unowned self] recognizer in
                if self.contentView.childFirstResponder() != nil {
                    self.view.endEditing(true)
                    self.isTextPanelActive.accept(false)
                } else {
                    self.viewModel.inputs.textChunkInsertRequest()
                    self.contentView.arrangedSubviews.last?.becomeFirstResponder()
                }
        }
        .disposed(by: disposeBag)
    }
    
    private func panelButtonBuilder(_ image: String, _ action: @escaping () -> ()) -> UIButton {
        let button = UIButton()
        button.rx.tap
        .bind(onNext: action)
        .disposed(by: disposeBag)
        button.setImage(UIImage(systemName: image), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        return button
    }
    
    private func setupPanel() {
        view.addSubview(buttonsPanel)
        
        let commonButtons: [UIButton] = [
            panelButtonBuilder("plus", { [weak self] in
                self?.viewModel.inputs.photoChunkInsertRequest()
            }),
            panelButtonBuilder("mappin", { [weak self] in
                self?.viewModel.inputs.mapChunkInsertRequest()
            }),
            panelButtonBuilder("paintbrush", { [weak self] in
                self?.viewModel.inputs.graffitiChunkInsertRequest()
            })
        ]
        
        let textEditButtons: [UIButton] = [
            panelButtonBuilder("bold", { [weak self] in
                if let view = self?.contentView.childFirstResponder() as? UITextView,
                    let font = view.typingAttributes[.font] as? UIFont {
                    if font.isBold() {
                        view.typingAttributes[.font] = font.undoBold()
                    } else {
                        view.typingAttributes[.font] = font.bold()
                    }
                }
            }),
            panelButtonBuilder("italic", { [weak self] in
                if let view = self?.contentView.childFirstResponder() as? UITextView,
                    let font = view.typingAttributes[.font] as? UIFont {
                    if font.isItalic() {
                        view.typingAttributes[.font] = font.undoItalic()
                    } else {
                        view.typingAttributes[.font] = font.italic()
                    }
                }
            }),
            panelButtonBuilder("underline", { [weak self] in
                if let view = self?.contentView.childFirstResponder() as? UITextView {
                    if let value = view.typingAttributes[.underlineStyle] as? NSNumber {
                        if value.intValue == 1 {
                            view.typingAttributes[.underlineStyle] = 0
                        }
                    } else {
                        view.typingAttributes[.underlineStyle] = 1
                    }
                }
            }),
            panelButtonBuilder("strikethrough", { [weak self] in
                if let view = self?.contentView.childFirstResponder() as? UITextView {
                    if let value = view.typingAttributes[.strikethroughStyle] as? NSNumber {
                        if value.intValue == 1 {
                            view.typingAttributes[.strikethroughStyle] = 0
                        }
                    } else {
                        view.typingAttributes[.strikethroughStyle] = 1
                    }
                }
            })
            ]
        
        textEditButtons.forEach {
            isTextPanelActive
            .map { !$0 }
            .bind(to: $0.rx.isHidden)
            .disposed(by: disposeBag)
        }
        
        commonButtons.forEach { button in
            isTextPanelActive
            .bind(to: button.rx.isHidden)
            .disposed(by: disposeBag)
        }
        
        buttonsPanel.buttons.accept(commonButtons + textEditButtons + [
            textFormatButton,
            endEditButton
        ])
        
        textFormatButton.rx.tap
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.3) {
                    if let current = self?.isTextPanelActive.value {
                        self?.isTextPanelActive.accept(!current)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        endEditButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.view.endEditing(true)
                self.isTextPanelActive.accept(false)
            }).disposed(by: disposeBag)
        
        buttonsPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonsPanelBottomConstraint = buttonsPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        buttonsPanelBottomConstraint.isActive = true
        buttonsPanel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    }
    
    func setupScrollView() {
        let safeGuide = view.safeAreaLayoutGuide
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.contentInset.bottom = 75
        
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        
        scrollView.contentSize = contentView.bounds.size
        scrollView.sizeToFit()
        
        scrollView.backgroundColor = UIColor.white
        
        keyboardHeight().subscribe(onNext: { [weak self] (inset) in
            if let self = self {
                let additionalInset: CGFloat = inset == 0 ? 75 : 0
                let panelInset: CGFloat = inset == 0 ? 10 : -self.view.safeAreaInsets.bottom + 10
                self.buttonsPanelBottomConstraint.constant = (-inset - panelInset)
                UIView.animate(withDuration: 0.3) {
                    if inset == 0 {
                        self.isTextPanelActive.accept(false)
                    }
                    self.view.layoutIfNeeded()
                    self.textFormatButton.isHidden.toggle()
                    self.endEditButton.isHidden.toggle()
                }
                self.scrollView.contentInset = .init(top: 0, left: 0, bottom: inset + additionalInset, right: 0)
            }
        }).disposed(by: disposeBag)
        
    }
    
    func keyboardHeight() -> Observable<CGFloat> {
        return Observable
                .from([
                    NotificationCenter.default
                        .rx.notification(UIResponder.keyboardWillShowNotification)
                        .map { notification -> CGFloat in
                            (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                        },
                    NotificationCenter.default
                        .rx.notification(UIResponder.keyboardWillHideNotification)
                        .map { _ -> CGFloat in
                            0
                        }
                ])
                .merge()
    }
}


extension UIFont {
        
    // MARK: Bold
    
    func bold() -> UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.insert([.traitBold])
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return .init(descriptor: descriptor, size: 0)
        }
        return self
    }
    
    func undoBold() -> UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.remove([.traitBold])
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return .init(descriptor: descriptor, size: 0)
        }
        return self
    }
    
    func isBold() -> Bool {
        fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    // MARK: Italic
    
    func italic() -> UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.insert([.traitItalic])
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return .init(descriptor: descriptor, size: 0)
        }
        return self
    }
    
    func undoItalic() -> UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.remove(.traitItalic)
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return .init(descriptor: descriptor, size: 0)
        }
        return self
    }
    
    func isItalic() -> Bool {
        fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
}

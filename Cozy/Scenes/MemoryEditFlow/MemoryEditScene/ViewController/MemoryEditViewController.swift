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




// MARK: View Model Declaration


enum MemoryCreateCollectionItem {
    case TextItem(viewModel: TextChunkViewModelType)
    case PhotoItem(viewModel: PhotoChunkViewModelType)
    case GraffitiItem(viewModel: GraffitiChunkViewModelType)
}

protocol MemoryCreateViewModelOutput {
    var items: BehaviorRelay<[MemoryCreateCollectionItem]> { get }
    var title: Driver<String> { get }
    
    
    var photoInsertRequestObservable: Observable<Void> { get }
    var photoDetailRequestObservable: Observable<Data> { get }
    var photoShareRequestObservable: Observable<Data> { get }
    
    var mapInsertRequestObservable: Observable<Void> { get }
    
    var graffitiInsertRequestObservable: Observable<Void> { get }
}

protocol MemoryCreateViewModelInput {
    var saveRequest: () -> () { get }
    
    var textChunkInsertRequest: () -> () { get }
    var photoChunkInsertRequest: () -> () { get }
    var mapChunkInsertRequest: () -> () { get }
    var graffitiChunkInsertRequest: () -> () { get }
    
    var photoInsertResponse: (ImageMeta) -> () { get }
    var graffitiInsertResponse: (Data) -> () { get }
}

protocol MemoryCreateViewModelType {
    var outputs: MemoryCreateViewModelOutput { get }
    var inputs: MemoryCreateViewModelInput { get }
}


// MARK: Controller


class MemoryEditViewController: NMViewController {

    let viewModel: MemoryCreateViewModelType!
    
    private var buttonsPanelBottomConstraint: NSLayoutConstraint!
    private let isTextPanelActive = BehaviorRelay<Bool>(value: false)
    private let isFontEditPanelActive = BehaviorRelay<Bool>(value: false)
    
    // MARK: Transition
    private var imageViewToPresent: UIImageView!
    private var rectToPresent: CGRect!
    
    private var commonButtons: [NMButton] = []
    private var textEditButtons: [NMButton] = []
    
    // MARK: Init
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
    
    lazy var endEditButton: NMButton = {
        let button = NMButton(frame: .zero)
        button.setImage(UIImage(systemName: "chevron.down.circle"), for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    lazy var textFormatButton: NMButton = {
        let button = NMButton(frame: .zero)
        button.setImage(UIImage(systemName: "a"), for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        bindViewModel()
        setupPanel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isFontEditPanelActive.accept(false)
        isTextPanelActive.accept(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.inputs.saveRequest()
    }
    
    func bindViewModel() {

        viewModel.outputs.items.map { $0.map { [unowned self] (item) -> UIView in
            switch item {
            case let .PhotoItem(viewModel):
                let view = PhotoChunkMemoryView()
                
                view.tapDriver.asObservable()
                    .subscribe(onNext: {
                        self.imageViewToPresent = view.imageView
                        self.rectToPresent = view.imageView.convert(view.imageView.frame, to: self.view.window)
                    })
                .disposed(by: self.disposeBag)
                
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
                    self.isFontEditPanelActive.accept(false)
                } else {
                    self.viewModel.inputs.textChunkInsertRequest()
                    self.contentView.arrangedSubviews.last?.becomeFirstResponder()
                }
        }
        .disposed(by: disposeBag)
        
        viewModel.outputs.title
            .drive(navigationItem.rx.title)
        .disposed(by: disposeBag)
    }
    
    private func panelButtonBuilder(_ image: String, _ action: @escaping () -> ()) -> NMButton {
        let button = NMButton()
        button.rx.tap
        .bind(onNext: action)
        .disposed(by: disposeBag)
        button.setImage(UIImage(systemName: image), for: .normal)
        button.backgroundColor = .clear
        return button
    }
    
    private func setupPanel() {
        view.addSubview(buttonsPanel)
        
        setupPanelButtons()
        
        textEditButtons.forEach { button in
            isFontEditPanelActive
            .map { !$0 }
            .bind(onNext: { (value) in
                button.isHidden = value
                button.alpha = value ? 0 : 1
            })
            .disposed(by: disposeBag)
        }
        
        commonButtons.forEach { button in
            isFontEditPanelActive
            .bind(onNext: { (value) in
                button.isHidden = value
                button.alpha = value ? 0 : 1
            })
            .disposed(by: disposeBag)
        }
        
        commonButtons.forEach {
            isTextPanelActive
            .bind(to: $0.rx.isHidden)
            .disposed(by: disposeBag)
        }
                
        isTextPanelActive
            .map { !$0 }
            .bind { [weak self] (value) in
                guard let self = self else { return }
                let duration = value ? 0.15 : 0.3
                UIView.animate(withDuration: duration) {
                    self.endEditButton.isHidden = value
                    self.endEditButton.alpha = value ? 0 : 1
                    
                    self.textFormatButton.isHidden = value
                    self.textFormatButton.alpha = value ? 0 : 1
                    
                    
                }
        }
        .disposed(by: disposeBag)
        
        buttonsPanel.buttons.accept(
            commonButtons + textEditButtons + [
            textFormatButton,
            endEditButton
        ])
        
        textFormatButton.rx.tap
            .subscribe(onNext: { [weak self] in
                if let current = self?.isFontEditPanelActive.value {
                    UIView.animate(withDuration: 0.15) {
                        self?.isFontEditPanelActive.accept(!current)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        endEditButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.isFontEditPanelActive.accept(false)
                self?.isTextPanelActive.accept(false)
                self?.view.endEditing(true)
            }).disposed(by: disposeBag)

        
        
        buttonsPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonsPanelBottomConstraint = buttonsPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        buttonsPanelBottomConstraint.isActive = true
    }
    
    private func setupPanelButtons() {
        let textEditButtons: [NMButton] = [
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
        
        let commonButtons: [NMButton] = [
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
        
        self.textEditButtons.append(contentsOf: textEditButtons)
        self.commonButtons.append(contentsOf: commonButtons)
    }
    
    func setupScrollView() {
        let safeGuide = view.safeAreaLayoutGuide
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollView.contentInset.bottom = 150
        scrollView.contentInset.top = 10
        
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: kSideInset).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -kSideInset).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -2*kSideInset).isActive = true
        
        contentView.insetsLayoutMarginsFromSafeArea = true
        
        scrollView.contentSize = contentView.bounds.size
        scrollView.sizeToFit()
        
//        scrollView.backgroundColor = UIColor.white
        
        keyboardHeight().subscribe(onNext: { [weak self] (rect) in
            if let self = self {
                let safeInset = self.view.safeAreaInsets
                let additionalInset: CGFloat = rect.height == 0 ? 150 : 50
                let panelInset: CGFloat = rect.height == 0 ? -10 : safeInset.bottom - 10
                self.buttonsPanelBottomConstraint.constant = (-rect.height + panelInset)
                UIView.animate(withDuration: 0.3) {
                    if rect.height == 0 {
                        self.isTextPanelActive.accept(false)
                    }
                    self.view.layoutIfNeeded()
                    self.textFormatButton.isHidden.toggle()
                    self.endEditButton.isHidden.toggle()
                }
                self.scrollView.contentInset = .init(top: 0, left: 0, bottom: rect.height + additionalInset, right: 0)
            }
        }).disposed(by: disposeBag)
        
    }
    
    func keyboardHeight() -> Observable<CGRect> {
        return Observable
                .from([
                    NotificationCenter.default
                        .rx.notification(UIResponder.keyboardWillShowNotification)
                        .map { notification -> CGRect in
                            (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
                        },
                    NotificationCenter.default
                        .rx.notification(UIResponder.keyboardWillHideNotification)
                        .map { _ -> CGRect in
                            .zero
                        }
                ])
                .merge()
    }
}

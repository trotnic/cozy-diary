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


extension UIView {
    func childFirstResponder() -> UIView? {
        if self.isFirstResponder { return self }
        for subview in subviews {
            let firstResponder = subview.childFirstResponder()
            if firstResponder != nil {
                return firstResponder
            }
        }
        return nil
    }
    
    
}

class MemoryCreateViewController: BaseViewController {

    let viewModel: MemoryCreateViewModelType!
    
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
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        bindViewModel()
        setupPanel()
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
                } else {
                    self.viewModel.inputs.textChunkInsertRequest()
                    self.contentView.arrangedSubviews.last?.becomeFirstResponder()
                }
        }
        .disposed(by: disposeBag)
    }
    
    private func setupPanel() {
        view.addSubview(buttonsPanel)
        
        buttonsPanel.buttons.accept([
            {
            let button = UIButton(frame: .zero)
            button.rx.tap.bind { [weak self] in
                self?.viewModel.inputs.photoChunkInsertRequest()
            }.disposed(by: disposeBag)
            button.setTitle("➕", for: .normal)
            button.backgroundColor = .clear
            return button
          }()
        ])
        
        buttonsPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonsPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
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
            let additionalInset: CGFloat = inset == 0 ? 75 : 0
            self?.scrollView.contentInset = .init(top: 0, left: 0, bottom: inset + additionalInset, right: 0)
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


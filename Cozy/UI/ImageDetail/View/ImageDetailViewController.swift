//
//  ImageDetailViewController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/19/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ImageDetailViewController: BaseViewController {

    let viewModel: ImageDetailViewModelType!
    
    init(_ viewModel: ImageDetailViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) has not implemented")
    }
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.maximumZoomScale = 3
        view.minimumZoomScale = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var closeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "xmark"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var shareButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var initialTouchPoint: CGPoint = .zero
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupStackView()
        bindViewModel()
        setupHeaderView()
        setupViewGestureSensitivity()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        scrollView.setZoomScale(1, animated: false)
    }
    
    // MARK: Utility
    
    func bindViewModel() {
        
        viewModel.outputs.image.subscribe(onNext: { [weak self] (image) in
            DispatchQueue.global(qos: .userInteractive).async {
                if let image = UIImage(data: image) {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                        self?.view.backgroundColor = image.averageColor
                        self?.closeButton.backgroundColor = image.averageColor
                        self?.shareButton.backgroundColor = image.averageColor
                    }
                }
            }
        }).disposed(by: disposeBag)
        
        closeButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.inputs.closeObserver.accept(())
        }).disposed(by: disposeBag)
        
        shareButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.inputs.shareObserver.accept(())
        }).disposed(by: disposeBag)
        
    }
    
    private func setupHeaderView() {
        let safeGuide = view.safeAreaLayoutGuide
        
        
        view.addSubview(headerView)
        headerView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 65).isActive = true
        
        
        headerView.addSubview(closeButton)
        closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 40).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        closeButton.layer.cornerRadius = 25
        closeButton.layer.masksToBounds = true
        closeButton.tintColor = .white
        
        
        headerView.addSubview(shareButton)
        shareButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -40).isActive = true
        shareButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        shareButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        shareButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        shareButton.layer.cornerRadius = 25
        shareButton.layer.masksToBounds = true
        shareButton.tintColor = .white
    }
    
    private func setupViewGestureSensitivity() {
        let tapReco = UITapGestureRecognizer()
        tapReco.rx.event
            .subscribe(onNext: { [unowned self] (_) in
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.headerView.alpha = self.headerView.alpha == 1.0 ? 0.0 : 1.0
                })
        }).disposed(by: disposeBag)
        
        view.addGestureRecognizer(tapReco)
        
        let panReco = UIPanGestureRecognizer()
        panReco.rx.event.subscribe(onNext: { [unowned self] (recognizer) in
            
            if recognizer.state == .began {
                self.headerView.alpha = 0
                self.initialTouchPoint = recognizer.location(in: self.view)
            }
            if recognizer.state == .changed {
                let yTranslate = recognizer.location(in: self.view).y - self.initialTouchPoint.y
                if yTranslate > 0 {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.transform = CGAffineTransform(translationX: 0, y: yTranslate)
                    })
                }
                if yTranslate > 250 {
                    self.viewModel.inputs.closeObserver.accept(())
                }
            }
            if recognizer.state == .ended {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.transform = .identity
                    self.initialTouchPoint = .zero
                })
                
            }
        }).disposed(by: disposeBag)
        view.addGestureRecognizer(panReco)
    }
    
    private func setupScrollView() {
        let safeGuide = view.safeAreaLayoutGuide
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor).isActive = true
    }
    
    private func setupStackView() {
        let safeGuide = view.safeAreaLayoutGuide
        scrollView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: safeGuide.widthAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: safeGuide.heightAnchor).isActive = true
        stackView.addArrangedSubview(imageView)
    }
    
}


extension ImageDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

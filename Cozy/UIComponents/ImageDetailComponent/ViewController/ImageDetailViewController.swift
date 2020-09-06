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


class ImageDetailViewController: NMViewController {

    let viewModel: ImageDetailViewModelType
    let transitionDelegate = ImageDetailTransitioningDelegate()
    
    init(_ viewModel: ImageDetailViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) has not implemented")
    }
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isUserInteractionEnabled = true
        view.delegate = self
        view.maximumZoomScale = 3
        view.minimumZoomScale = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.isUserInteractionEnabled = true
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
    
    lazy var moreButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "ellipsis"), for: .normal)
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
        
        transitioningDelegate = transitionDelegate
        view.isUserInteractionEnabled = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        scrollView.setZoomScale(1, animated: false)
    }
    
    // MARK: Utility
    
    func bindViewModel() {
        
        viewModel
            .outputs
            .image
            .subscribe(onNext: { [weak self] (image) in
                DispatchQueue.global(qos: .userInteractive).async {
                    if let image = UIImage(data: image) {
                        DispatchQueue.main.async {
                            self?.imageView.image = image
                            self?.view.backgroundColor = image.averageColor
                            self?.closeButton.backgroundColor = image.averageColor
                            self?.moreButton.backgroundColor = image.averageColor
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        closeButton
            .rx.tap
            .subscribe(onNext: { [weak self] in
                self?.transitionDelegate.shouldDoInteractive = false
                self?.viewModel.inputs.closeButtonTap.accept(())
            })
            .disposed(by: disposeBag)
        
        moreButton
            .rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.inputs.moreButtonTap.accept(())
            })
            .disposed(by: disposeBag)
        
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
        closeButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        closeButton.layer.cornerRadius = 25
        closeButton.layer.masksToBounds = true
        closeButton.tintColor = .white
        
        
        headerView.addSubview(moreButton)
        moreButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20).isActive = true
        moreButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        moreButton.layer.cornerRadius = 25
        moreButton.layer.masksToBounds = true
        moreButton.tintColor = .white
    }
    
    private func setupViewGestureSensitivity() {
        let tapReco = UITapGestureRecognizer()
        
        tapReco
            .rx.event
            .subscribe(onNext: { [unowned self] (_) in
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.headerView.alpha = self.headerView.alpha == 1.0 ? 0.0 : 1.0
                })
            }).disposed(by: disposeBag)
        
        view.addGestureRecognizer(tapReco)
        
        
        let panReco = UIPanGestureRecognizer()
        
        panReco
            .rx.event
            .subscribe(onNext: { [unowned self] (recognizer) in

                if recognizer.state == .began {
                    self.initialTouchPoint = recognizer.location(in: self.view.window)
                    self.dismiss(animated: true)
                }
                if recognizer.state == .changed {
                    let point = recognizer.location(in: self.view.window)
                    
                    if point.y > self.initialTouchPoint.y {
                        let progress = abs(point.y - self.initialTouchPoint.y) / (1.7*self.view.frame.height)
                        self.transitionDelegate.interactionTransition.update(progress)
                    }
                }
                if recognizer.state == .ended {
                    let point = recognizer.location(in: self.view.window)
                    let requiredDistance = (self.view.window?.bounds.height ?? 300) * 0.2
                    let shouldFinish = abs(point.y) - abs(self.initialTouchPoint.y) >= requiredDistance
                    
                    if shouldFinish {
                        self.transitionDelegate.interactionTransition.finish()
                    } else {
                        self.transitionDelegate.interactionTransition.cancel()
                    }
                }
                
                if recognizer.state == .cancelled {
                    self.transitionDelegate.interactionTransition.cancel()
                }
            })
            .disposed(by: disposeBag)
        
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

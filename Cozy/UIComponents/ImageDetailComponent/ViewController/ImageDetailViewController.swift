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


private let kButtonSize: CGFloat = 50
private let kButtonCornerRadius: CGFloat = 25
private let kHeaderSize: CGFloat = 50
private let kMinZoomScale: CGFloat = 1
private let kMaxZoomScale: CGFloat = 3

class ImageDetailViewController: NMViewController {
    
    private var initialTouchPoint: CGPoint = .zero
    private let disposeBag = DisposeBag()

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
        view.maximumZoomScale = kMaxZoomScale
        view.minimumZoomScale = kMinZoomScale
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
    
    lazy var closeButton: UIButton = { buttonFactory(name: "xmark") }()
    lazy var moreButton: UIButton = { buttonFactory(name: "ellipsis") }()
    
    lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupStackView()
        bindViewModel()
        setupHeaderView()
        setupGestures()
        
        transitioningDelegate = transitionDelegate
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        scrollView.setZoomScale(kMinZoomScale, animated: false)
    }
    
    
    // MARK: Utility
    private func bindViewModel() {
        
        let outputs = viewModel.outputs
        let inputs = viewModel.inputs
        
        outputs
            .image
            .bind(onNext: { [weak self] (image) in
                DispatchQueue.global(qos: .userInteractive).async {
                    if let image = UIImage(data: image) {
                        let averageColor = image.averageColor
                        DispatchQueue.main.async {
                            self?.imageView.image = image
                            self?.view.backgroundColor = averageColor
                            self?.closeButton.backgroundColor = averageColor
                            self?.moreButton.backgroundColor = averageColor
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        closeButton
            .rx.tap
            .bind(onNext: { [weak self] in
                self?.transitionDelegate.shouldDoInteractive = false
                self?.dismiss(animated: true)
                inputs.closeButtonTap.accept(())
            })
            .disposed(by: disposeBag)
        
        moreButton
            .rx.tap
            .bind(to: inputs.moreButtonTap)
            .disposed(by: disposeBag)
        
    }
    
    private func setupHeaderView() {
        let safeGuide = view.safeAreaLayoutGuide
        
        
        view.addSubview(headerView)
        headerView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: kHeaderSize).isActive = true
        
        
        headerView.addSubview(closeButton)
        closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        closeButton.layer.cornerRadius = kButtonCornerRadius
        closeButton.layer.masksToBounds = true
        closeButton.tintColor = .white
        
        
        headerView.addSubview(moreButton)
        moreButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20).isActive = true
        moreButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        moreButton.layer.cornerRadius = kButtonCornerRadius
        moreButton.layer.masksToBounds = true
        moreButton.tintColor = .white
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
    
    private func setupGestures() {
        setupSwitchAppearanceRecognizer()
        setupDragToDismissRecognizer()
        setupZoomRecozniger()
    }
    
    private func setupSwitchAppearanceRecognizer() {
        let tapReco = UITapGestureRecognizer()
        tapReco.numberOfTapsRequired = 1
        
        tapReco
            .rx.event
            .bind(onNext: { [weak self] (recognizer) in
                if let alpha = self?.headerView.alpha {
                    UIView.animate(withDuration: 0.3, animations: {
                        self?.headerView.alpha = 1 - alpha
                    })
                }
            }).disposed(by: disposeBag)
        
        view.addGestureRecognizer(tapReco)
    }
    
    private func setupDragToDismissRecognizer() {
        let panReco = UIPanGestureRecognizer()
        
        panReco
            .rx.event
            .bind(onNext: { [unowned self] (recognizer) in

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
    
    private func setupZoomRecozniger() {
        let tapReco = UITapGestureRecognizer()
        tapReco.numberOfTapsRequired = 2
        
        tapReco
            .rx.event
            .bind { [unowned self] (recognizer) in
                let center = recognizer.location(in: self.imageView)
                let zoomRect = self.zoomRectForScale(scale: kMaxZoomScale, center: center)
                self.scrollView.zoom(to: zoomRect, animated: true)
            }
            .disposed(by: disposeBag)
        
        view.addGestureRecognizer(tapReco)
    }
    
    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect: CGRect = .zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        
        let newCenter = scrollView.convert(center, to: imageView)
        zoomRect.origin.x = newCenter.x - zoomRect.size.width / 2
        zoomRect.origin.y = newCenter.y - zoomRect.size.height / 2
        return zoomRect
    }
}

extension ImageDetailViewController {
    private func buttonFactory(name: String) -> UIButton {
        let view = UIButton()
        view.setImage(UIImage(systemName: name), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension ImageDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

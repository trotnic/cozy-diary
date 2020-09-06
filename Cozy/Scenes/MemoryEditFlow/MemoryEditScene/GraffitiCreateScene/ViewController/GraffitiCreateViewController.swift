//
//  GraffitiCreateViewController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/24/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import PencilKit

class GraffitiCreateViewController: NMViewController {
    private let disposeBag = DisposeBag()
    
    let viewModel: GraffitiCreateViewModelType
    
    private var landscapeConstraints = [NSLayoutConstraint]()
    private var portraitConstraints = [NSLayoutConstraint]()
    
    init(viewModel: GraffitiCreateViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var drawView: NMCanvasView = {
        let view = NMCanvasView(frame: UIScreen.main.bounds)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()
        setupDrawView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let window = view.window,
            let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: drawView)
            toolPicker.addObserver(drawView)
            drawView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }
    
    private func setupHeaderView() {
        setupCloseButton()
        setupSaveButton()
    }
    
    private func setupCloseButton() {
        
        let closeButton = NMButton()
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        
        closeButton
            .rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.inputs.closeButtonTap.accept(())
            }).disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
    }
    
    private func setupSaveButton() {
        
        let saveButton = NMButton()
        saveButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        
        saveButton
            .rx.tap
            .subscribe(onNext: { [weak self] in
                if let self = self {
                    DispatchQueue.global(qos: .userInitiated).async {
                        let image = self.drawView.drawing.image(from: self.drawView.drawing.bounds, scale: 1.0)
                        if let data = image.pngData() {
                            DispatchQueue.main.async {
                                self.viewModel.inputs.saveButtonTap.accept(data)
                            }                            
                        }
                    }
                }
            }).disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }
    
    private func setupDrawView() {
            
        view.addSubview(drawView)
        
        let safeGuide = view.safeAreaLayoutGuide
        
        drawView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        drawView.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        drawView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        drawView.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor).isActive = true
    }

}

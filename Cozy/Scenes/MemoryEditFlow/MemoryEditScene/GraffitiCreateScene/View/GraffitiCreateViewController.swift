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

    let viewModel: GraffitiCreateViewModelType
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: GraffitiCreateViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var drawView: NMCanvasView = {
        let view = NMCanvasView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupHeaderView()
        setupDrawView()
    }
    
    private func setupHeaderView() {
        setupCloseButton()
        setupSaveButton()
    }
    
    private func setupCloseButton() {
        
        let closeButton = NMButton()
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.inputs.closeRequest()
            }).disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
    }
    
    private func setupSaveButton() {
        
        let saveButton = NMButton()
        saveButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        
        
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                if let self = self {
                    DispatchQueue.global(qos: .userInitiated).async {
                        let image = self.drawView.drawing.image(from: self.drawView.drawing.bounds, scale: 1.0)
                        if let data = image.pngData() {
                            DispatchQueue.main.async {
                                self.viewModel.inputs.saveRequest(data)
                            }                            
                        }
                    }
                }
            }).disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }
    
    private func setupDrawView() {
            
        view.backgroundColor = .white
        view.addSubview(drawView)
        
        let safeGuide = view.safeAreaLayoutGuide
        
        drawView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        drawView.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        drawView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        drawView.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor).isActive = true
        
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
}

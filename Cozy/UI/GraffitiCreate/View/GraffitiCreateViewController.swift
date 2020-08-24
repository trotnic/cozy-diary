//
//  GraffitiCreateViewController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/24/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyDraw

class GraffitiCreateViewController: BaseViewController {

    let viewModel: GraffitiCreateViewModelType
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: GraffitiCreateViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var drawView: SwiftyDrawView = {
        let view = SwiftyDrawView()
        view.brush = .marker
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var closeButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var saveButton: UIButton = {
        let view = UIButton()
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
        view.addSubview(headerView)
        
        let safeGuide = view.safeAreaLayoutGuide
        
        headerView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        view.addSubview(dividerView)
        
        dividerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dividerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dividerView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        dividerView.heightAnchor.constraint(equalToConstant: 1.25).isActive = true
        
    
        
        setupCloseButton()
        setupSaveButton()
    }
    
    private func setupCloseButton() {
        
        headerView.addSubview(closeButton)
        
        closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 55).isActive = true
        
        closeButton.tintColor = .black
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.inputs.closeRequest()
            }).disposed(by: disposeBag)
    }
    
    private func setupSaveButton() {
        
        headerView.addSubview(saveButton)
        
        saveButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 55).isActive = true
        
        saveButton.tintColor = .black
        saveButton.backgroundColor = .clear
        saveButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let encoder = JSONEncoder()
                if let data = try? encoder.encode(self?.drawView.drawItems) {
                    self?.viewModel.inputs.saveRequest(data)
                }
            }).disposed(by: disposeBag)
    }
    
    private func setupDrawView() {
            
        view.backgroundColor = .white
        view.addSubview(drawView)
        
        let safeGuide = view.safeAreaLayoutGuide
        
        let screenWidth = UIScreen.main.bounds.width
        
//        drawView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        drawView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        drawView.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        drawView.heightAnchor.constraint(equalToConstant: screenWidth).isActive = true
        drawView.centerXAnchor.constraint(equalTo: safeGuide.centerXAnchor).isActive = true
        drawView.backgroundColor = .red
//        drawView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
//        drawView.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor).isActive = true
        
    }
}

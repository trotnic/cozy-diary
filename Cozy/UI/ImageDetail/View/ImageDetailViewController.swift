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

    let viewModel: ImageDetailViewModel
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
//        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let disposeBag = DisposeBag()
    
    init(_ viewModel: ImageDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) has not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let safeGuide = view.safeAreaLayoutGuide
        
        view.addSubview(scrollView)
        
        scrollView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor).isActive = true
        
        scrollView.addSubview(stackView)
        
        
        
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: safeGuide.widthAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: safeGuide.heightAnchor).isActive = true
        
        stackView.addArrangedSubview(imageView)
        
        

        viewModel.image.subscribe(onNext: { [weak self] (image) in
            if let image = UIImage(data: image) {
                self?.imageView.image = image
            }
        }).disposed(by: disposeBag)
    }
    
    
    func setupImageView() {
        
        view.addSubview(imageView)
        
//        imageView
        
    }
}

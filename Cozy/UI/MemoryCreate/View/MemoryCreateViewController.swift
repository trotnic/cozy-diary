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

protocol Memorizable {
    func getView() -> UIView
}

protocol MemoryCreateViewModelProtocol {
    
    var viewDidLoad: PublishRelay<Void> { get }
    
}

class MemoryCreateViewController: BaseViewController {

    let viewModel: MemoryCreateViewModelProtocol
    
    init(_ viewModel: MemoryCreateViewModelProtocol) {
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
    
    private let disposeBag = DisposeBag()
    
    private var viewsStack: Array<Memorizable> = []
    
    private var currentMemory: Memorizable!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad.accept(())
        
        setupScrollView()
    }
    
    func setupScrollView() {
        let safeGuide = view.safeAreaLayoutGuide
    
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor).isActive = true
        
        
        let tapGesture = UITapGestureRecognizer()
        
        scrollView.addGestureRecognizer(tapGesture)
        scrollView.backgroundColor = .white
        tapGesture
            .rx.event
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self] recognizer in
                
        }
        .disposed(by: disposeBag)
        
    }

}

struct MemorizableViewFactory {
    
    static func textView() -> MemorizableTextView {
        
        let view = MemorizableTextView()
        
        return view
        
    }
    
}

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

protocol MemoryCreateViewModelProtocol {
    
    var viewDidLoad: PublishRelay<Void> { get }
    var viewDidAddTextChunk: PublishRelay<Void> { get }
    var currentMemory: BehaviorSubject<Memory> { get }
    var chunks: Array<TextChunkViewModel> { get }
    
}

class MemoryCreateViewController: BaseViewController {
    
    enum ChunkType {
        case text, photo
    }

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
    
    lazy var contentView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let disposeBag = DisposeBag()
    private var viewsStack: Array<MemorizableView> = []
    private var currentMemory: MemorizableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad.accept(())
        
        setupScrollView()
        setupChunks()
        setupAddButton()
    }
    
    func setupAddButton() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.add, style: .plain, target: self, action: #selector(doThings))
        
    }
    
    @objc func doThings() {
        
    }
    
    func setupChunks() {
        
        viewModel.chunks.forEach { [weak self] viewModel in
            self?.addTextChunk(viewModel: viewModel)
        }
        
    }
    
    func addTextChunk(viewModel: TextChunkViewModel) {
        let view = TextChunkView(viewModel)
        view.sizeToFit()
        view.font = .systemFont(ofSize: 25)
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
        view.isScrollEnabled = false
        view.backgroundColor = .red
        contentView.addArrangedSubview(view)
        viewsStack.append(view)
        currentMemory = view
        
    }
    
    func setupScrollView() {
        let safeGuide = view.safeAreaLayoutGuide
    
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor).isActive = true
        scrollView.contentInset.bottom = 150
        
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        
        scrollView.contentSize = contentView.bounds.size
        scrollView.sizeToFit()
        
    
        let tapGesture = UITapGestureRecognizer()
        
        scrollView.addGestureRecognizer(tapGesture)
        scrollView.backgroundColor = .white
        tapGesture
            .rx.event
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self] recognizer in
                print(self?.viewModel.chunks.first?.text.value)
        }
        .disposed(by: disposeBag)
        
    }
}


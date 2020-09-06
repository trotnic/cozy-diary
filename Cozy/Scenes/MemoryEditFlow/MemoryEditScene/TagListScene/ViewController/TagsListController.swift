//
//  TagsListController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/1/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alertift


class TagsListController: NMViewController {

    let viewModel: TagsListViewModelType
    
    private let disposeBag = DisposeBag()
    
    lazy var tableView: NMTableView = {
        let view = NMTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(NMTableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        return view
    }()
    
    lazy var addButton: NMButton = {
        let view = NMButton()
        view.setImage(UIImage(systemName: "plus"), for: .normal)
        return view
    }()
    
    lazy var closeButton: NMButton = {
        let view = NMButton()
        view.setTitle("Close", for: .normal)
        return view
    }()
    
    init(viewModel: TagsListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Tags"
        
        setupTableView()
        setupAddButton()
        setupCloseButton()
        bindViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.dismiss.accept(())
    }
    
    func bindViewModel() {
        viewModel
            .outputs
            .items
            .bind(to: tableView.rx.items(cellIdentifier: "reuseIdentifier")) { row, model, cell in
               cell.textLabel?.text = model
            }
            .disposed(by: disposeBag)
        
        
        tableView.rx
            .modelDeleted(String.self)
            .subscribe(onNext: { [weak self] (text) in
                self?.viewModel.inputs.tagRemove.accept(text)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        
        addButton
            .rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                Alertift.alert(title: "Add tag")
                .textField { (textField) in
                    
                    textField.superview?.backgroundColor = .clear

                    let view = textField.superview?.superview
                    view?.subviews.first?.alpha = 0
                    view?.backgroundColor = Alertift.Alert.backgroundColor?.withAlphaComponent(0.4)
                    
                    view?.layer.borderColor = Alertift.Alert.titleTextColor?.withAlphaComponent(0.2).cgColor
                    
                    view?.layer.cornerRadius = 4
                    view?.layer.masksToBounds = true
                    view?.layer.borderWidth = 1
                    
                    textField.textColor = Alertift.Alert.messageTextColor
                    textField.borderStyle = .none
                }
                .action(.default("Add")) { _, _, textFields in
                    if let text = textFields?.last?.text {
                        self.viewModel.inputs.tagInsert.accept(text)
                    }
                }
                .action(.cancel("Cancel"))
                .show(on: self)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupCloseButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        closeButton
            .rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.inputs.dismiss.accept(())
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
}

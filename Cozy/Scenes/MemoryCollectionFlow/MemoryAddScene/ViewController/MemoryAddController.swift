//
//  MemoryAddController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/30/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources


class MemoryAddController: NMViewController {

    let viewModel: MemoryAddViewModelType
    
    init(viewModel: MemoryAddViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<MemoryAddCollectionSection> = {
        RxTableViewSectionedReloadDataSource<MemoryAddCollectionSection>.init(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case .dateItem:
                let cell = DatePickTableViewCell()
                
                cell.datePicker.maximumDate = self.viewModel.inputs.selectedDate.value
            
                cell.datePicker
                    .rx.date
                    .bind(to: self.viewModel.inputs.selectedDate)
                    .disposed(by: self.disposeBag)
                
                return cell
            }
        }, titleForHeaderInSection: { (dataSource, section) -> String? in
            dataSource.sectionModels[section].title
        })
    }()
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle()
        setupTableView()
        setupCloseButton()
        setupConfirmButton()
        bindViewModel()
    }
    
    private func setupTitle() {
        navigationItem.title = "Add memory"
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.register(DatePickTableViewCell.self, forCellReuseIdentifier: DatePickTableViewCell.reuseIdentifier)
        
        tableView
            .rx.itemSelected
            .bind { [weak self] (indexPath) in                
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupCloseButton() {
        navigationButton(image: "xmark") { (button) in
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
            
            button
                .rx.tap
                .bind { [weak self] in
                    self?.viewModel.inputs.closeButtonTap.accept(())
                    self?.dismiss(animated: true)
                }
                .disposed(by: disposeBag)
        }
    }
    
    private func setupConfirmButton() {
        navigationButton(image: "checkmark") { (button) in
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
            
            button
                .rx.tap
                .bind { [weak self] in
                    self?.viewModel.inputs.confirmButtonTap.accept(())
                    self?.dismiss(animated: true)
                }
                .disposed(by: disposeBag)
        }
    }
    
    private func bindViewModel() {
        let outputs = viewModel.outputs
        let inputs = viewModel.inputs
        
        outputs
            .items
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: creational
    private func navigationButton(image: String, completion: (UIButton) -> ()) {
        let button = NMButton()
        button.setImage(UIImage(systemName: image), for: .normal)
        
        completion(button)
    }
}

// MARK: DataSource

enum MemoryAddCollectionItem {
    case dateItem
}

struct MemoryAddCollectionSection {
    var title: String
    var items: [MemoryAddCollectionItem]
}

extension MemoryAddCollectionSection: SectionModelType {
    typealias Item = MemoryAddCollectionItem
    
    
    init(original: Self, items: [Self.Item]) {
        self = original
    }
}

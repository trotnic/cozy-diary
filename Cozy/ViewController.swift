//
//  ViewController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/14/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ViewController: UIViewController {

    lazy var data: BehaviorRelay<[String]> = {
        
        let data = [
            "Apple",
            "Microsoft",
            "Google",
            "Tesla",
            "EPAM",
            "Facebook"
        ]
        return .init(value: data)
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(UITableViewCell.self, forCellReuseIdentifier: "iden")
        return view
    }()
    
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = tableView
    }
    
    var seq: Observable<Int> = {
        return .of(1,2,3,4,5,6)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data
            .bind(to: tableView.rx
                .items(cellIdentifier: "iden", cellType: UITableViewCell.self)) { row, element, cell in
                    cell.textLabel?.text = element
        }
        .disposed(by: disposeBag)
        
        tableView.rx
            .itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
        
        seq.subscribe(onNext: { (num) in
            print(num)
        }) 
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelDeleted(String.self)
            .subscribe(onNext: { [weak self] item in
                if let data = self?.data.value {
                    let newData = data.filter { string in
                        !string.elementsEqual(item)
                    }
                    self?.data.accept(newData)
                }
                
            })
        .disposed(by: disposeBag)
        
        
    }


}


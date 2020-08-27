//
//  BaseViewController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/15/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func stubSwipeToRight() {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
    }
    
    func stubSwipeToLeft() {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .left
        view.addGestureRecognizer(swipe)
    }
}

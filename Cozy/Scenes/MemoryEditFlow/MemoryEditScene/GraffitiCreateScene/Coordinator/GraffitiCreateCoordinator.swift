//
//  GraffitiCreateCoordinator.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/24/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol GraffitiCreateCoordinatorOutput {
    var saveObservable: Observable<Data> { get }
    var closeObservable: Observable<Void> { get }
}


class GraffitiCreateCoordinator: Coordinator, GraffitiCreateCoordinatorOutput {
    
    var outputs: GraffitiCreateCoordinatorOutput { return self }
    
    // MARK: Outputs
    let saveObservable: Observable<Data>
    let closeObservable: Observable<Void>
    
    // MARK: Private
    private let savePublisher = PublishSubject<Data>()
    private let closePublisher = PublishSubject<Void>()
    
    var viewController: GraffitiCreateViewController!
    let presentingController: UIViewController
    
    private let disposeBag = DisposeBag()
    
    init(_ presentingController: UIViewController) {
        self.presentingController = presentingController
        
        saveObservable = savePublisher.asObservable()
        closeObservable = closePublisher.asObservable()
    }
    
    func start() {
        let viewModel = GraffitiCreateViewModel()
        viewController = .init(viewModel: viewModel)
        
        let wrapController = NMNavigationController()
        wrapController.setViewControllers([viewController], animated: true)

        wrapController.modalPresentationStyle = .fullScreen
        
        
        viewModel
            .outputs
            .saveRequestObservable
            .subscribe(onNext: { [weak self] data in
                self?.savePublisher.onNext(data)
            })
            .disposed(by: disposeBag)
        
        
        viewModel
            .outputs
            .closeRequestObservable
            .subscribe(onNext: { [weak self] in
                self?.closePublisher.onNext(())
            })
            .disposed(by: disposeBag)
        
        
        presentingController.present(wrapController, animated: true)
        
    }
}

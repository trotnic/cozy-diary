//
//  UnsplashImageCollectionDataSource.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/28/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxDataSources


enum UnsplashCollectionItem {
    case common(viewModel: UnsplashImageCollectionCommonItemViewModelType)
}

struct UnsplashCollectionSection {
    var items: [UnsplashCollectionItem]
}

extension UnsplashCollectionSection: SectionModelType {
    typealias Item = UnsplashCollectionItem
    
    init(original: Self, items: [Item]) {
        self = original
    }
}

struct UnsplashCollectionDataSource {
    typealias DataSource = RxCollectionViewSectionedReloadDataSource
    
    static func dataSource() -> DataSource<UnsplashCollectionSection> {
        return .init(configureCell: { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
            switch dataSource[indexPath] {
            case let .common(viewModel):
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UnsplashCollectionCommonCell.reuseIdentifier, for: indexPath) as? UnsplashCollectionCommonCell {
                    cell.viewModel = viewModel
                    return cell
                }
                return .init()
            }
        })
    }
}

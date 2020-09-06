//
//  MemoryCollectionViewDataSource.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxDataSources


enum MemoryCollectionViewItem {
    case CommonItem(viewModel: MemoryCollectionCommonItemViewModelType)
}

struct MemoryCollectionViewSection {
    var items: [MemoryCollectionViewItem]
}

extension MemoryCollectionViewSection: SectionModelType {
    typealias Item = MemoryCollectionViewItem
    
    init(original: Self, items: [Self.Item]) {
        self = original
    }
}

struct MemoryCollectionViewDataSource {
    typealias DataSource = RxCollectionViewSectionedReloadDataSource
    
    static func dataSource() -> DataSource<MemoryCollectionViewSection> {
        return .init(configureCell: { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
            switch item {
            case let .CommonItem(viewModel):
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemoryCollectionViewCell.reuseIdentifier, for: indexPath) as? MemoryCollectionViewCell {
                    cell.viewModel = viewModel
                    return cell
                }
                return UICollectionViewCell()
            }
        })
    }
}

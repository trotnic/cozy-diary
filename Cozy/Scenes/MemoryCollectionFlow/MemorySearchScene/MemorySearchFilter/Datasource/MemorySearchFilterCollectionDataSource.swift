//
//  MemorySearchFilterCollectionDataSource.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 9/6/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import Foundation
import RxDataSources
import UIKit


enum MemorySearchFilterCollectionItem {
    case tagsItem(viewModel: MemorySearchFilterTagsViewModelType)
    case monthsItem(viewModel: MemorySearchFilterMonthsViewModelType)
}

struct MemorySearchFilterCollectionSection {
    var items: [MemorySearchFilterCollectionItem]
}

extension MemorySearchFilterCollectionSection: SectionModelType {
    typealias Item = MemorySearchFilterCollectionItem
    
    init(original: Self, items: [Self.Item]) {
        self = original
    }
}

struct MemorySearchFilterCollectionDataSource {
    typealias DataSource = RxCollectionViewSectionedReloadDataSource
    
    static func dataSource() -> DataSource<MemorySearchFilterCollectionSection> {
        return .init(configureCell: { (dataSource, tableView, indexPath, item) -> UICollectionViewCell in
            switch item {
            case let .tagsItem(viewModel):
                if let cell = tableView.dequeueReusableCell(withReuseIdentifier: MemorySearchFilterTagCell.reuseIdentifier, for: indexPath) as? MemorySearchFilterTagCell {
                    cell.bindViewModel(viewModel)
                    return cell
                }
                return .init()
            case let .monthsItem(viewModel):
                if let cell = tableView.dequeueReusableCell(withReuseIdentifier: MemorySearchFilterDateCell.reuseIdentifier, for: indexPath) as? MemorySearchFilterDateCell {
                    cell.bindViewModel(viewModel)
                    return cell
                }
                return .init()
            }
        })
    }
}

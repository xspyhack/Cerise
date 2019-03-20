//
//  ListUpdate.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/20.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation

enum TableViewUpdate {
    case reloadData
    case reloadRows([IndexPath])
    case reloadSections(IndexSet)
    case insertRows([IndexPath])
    case deleteRows([IndexPath])
    case insertSections(IndexSet)
    case deleteSections(IndexSet)
    case none
}

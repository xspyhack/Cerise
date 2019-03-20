//
//  ListUpdater.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/20.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

protocol ListViewUpdate {
}

enum ListViewUpdater<T: ListViewUpdate> {
    case batch([T])
    case normal(T)
}

enum TableViewUpdater {
    case batch([TableViewUpdate])
    case normal(TableViewUpdate)

    func performUpdate(to tableView: UITableView?,
                       with animation: UITableView.RowAnimation = .fade,
                       queue: DispatchQueue = DispatchQueue.main) {
        switch self {
        case .batch(let updates):
            TableViewUpdate.performBatchUpdates(updates, to: tableView, with: animation, queue: queue)
        case .normal(let update):
            update.performUpdate(to: tableView, with: animation, queue: queue)
        }
    }
}

extension TableViewUpdate: ListViewUpdate {
    func performUpdate(to tableView: UITableView?,
                       with animation: UITableView.RowAnimation = .fade,
                       queue: DispatchQueue = DispatchQueue.main) {
        guard let tableView = tableView else {
            return
        }

        switch self {
        case .reloadData:
            queue.safe.async {
                tableView.reloadData()
            }
        case .reloadRows(let rows):
            guard !rows.isEmpty else {
                return
            }
            queue.safe.async {
                tableView.reloadRows(at: rows, with: animation)
            }
        case .reloadSections(let sections):
            guard !sections.isEmpty else {
                return
            }

            queue.safe.async {
                tableView.reloadSections(sections, with: animation)
            }
        case .insertRows(let rows):
            guard !rows.isEmpty else {
                return
            }

            queue.safe.async {
                tableView.insertRows(at: rows, with: animation)
            }
        case .deleteRows(let rows):
            guard !rows.isEmpty else {
                return
            }

            queue.safe.async {
                tableView.deleteRows(at: rows, with: animation)
            }
        case .insertSections(let sections):
            guard !sections.isEmpty else {
                return
            }

            queue.safe.async {
                tableView.insertSections(sections, with: animation)
            }
        case .deleteSections(let sections):
            guard !sections.isEmpty else {
                return
            }

            queue.safe.async {
                tableView.deleteSections(sections, with: animation)
            }
        case .none:
            break
        }
    }

    static func performBatchUpdates(_ updates: [TableViewUpdate],
                                    to tableView: UITableView?,
                                    with animation: UITableView.RowAnimation = .fade,
                                    queue: DispatchQueue = DispatchQueue.main) {
        guard let tableView = tableView else {
            return
        }

        tableView.beginUpdates()
        updates.forEach { $0.performUpdate(to: tableView, queue: queue) }
        tableView.endUpdates()
    }

    var indexPaths: [IndexPath] {
        switch self {
        case .reloadRows(let paths):
            return paths
        case .insertRows(let paths):
            return paths
        case .deleteRows(let paths):
            return paths
        default:
            return []
        }
    }

    var indexSet: IndexSet? {
        switch self {
        case .reloadSections(let set):
            return set
        case .insertSections(let set):
            return set
        case .deleteSections(let set):
            return set
        default:
            return nil
        }
    }

    var isReload: Bool {
        switch self {
        case .reloadData:
            return true
        default:
            return false
        }
    }
}

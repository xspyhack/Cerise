//
//  MatterCell.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

protocol MatterCellModelType {
    var title: String { get }
    var days: Int { get }
//    var tag: String { get }
//    var notes: String { get }
//    var createdAt: TimeInterval { get }
}

extension MattersViewController {
    struct MatterCellModel: MatterCellModelType {
        var title: String
        var days: Int
//        var tag: String
//        var notes: String
//        let createdAt: TimeInterval

        init(matter: Matter) {
            self.title = matter.title
            self.days = 10// Date().cerise.absoluteDays(with: Date(timeIntervalSince1970: matter.happenedAt))
//            self.tag = (Tag(rawValue: matter.tag) ?? .red).value
//            self.notes = matter.body
//            self.createdAt = matter.createdAt
        }
    }
}

extension MattersViewController {
    final class MatterCell: UITableViewCell, Reusable {
        private lazy var daysLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 32.0, weight: .medium)
            label.text = "+333"
            label.textColor = UIColor.cerise.tint
            return label
        }()

        private lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 24.0, weight: .semibold)
            label.text = "Matter"
            label.textColor = UIColor.white
            return label
        }()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            setup()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setup() {
            selectionStyle = .none
            contentView.backgroundColor = UIColor.black

            contentView.addSubview(titleLabel)
            contentView.addSubview(daysLabel)
            titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            titleLabel.cerise.layout { builder in
                builder.centerY == contentView.centerYAnchor
                builder.leading == contentView.leadingAnchor + 16
            }

            daysLabel.cerise.layout { builder in
                builder.trailing == contentView.trailingAnchor - 16
                builder.leading >= titleLabel.trailingAnchor + 8
                builder.centerY == titleLabel.centerYAnchor
            }
        }

        override var layoutMargins: UIEdgeInsets {
            get {
                return UIEdgeInsets.zero
            }
            set {}
        }
    }
}

extension MattersViewController.MatterCell {
    func bind(with presenter: MatterCellModelType) {
        titleLabel.text = presenter.title
        daysLabel.text = (presenter.days > 0) ? "+\(presenter.days)" : "\(presenter.days)"
        //daysLabel.textColor = UIColor(hex: presenter.tag)
    }
}

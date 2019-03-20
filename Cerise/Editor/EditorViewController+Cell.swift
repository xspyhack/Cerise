//
//  EditorViewController+Cell.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/19.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension EditorViewController {
    final class TextFieldCell: UITableViewCell, Reusable {
        var textChanged: ControlEvent<String> {
            let source = textField.rx.text.orEmpty
                .map { $0.cerise.trimming(.whitespaceAndNewline) }
            return ControlEvent(events: source)
        }

        var textFieldDidBeginEditing: ControlEvent<Void> {
            return textField.rx.didBeginEditing
        }

        var textFieldDidEndEditing: ControlEvent<Void> {
            return textField.rx.didEndEditing
        }

        private(set) lazy var textField: UITextField = {
            let textField = UITextField()
            textField.textAlignment = .center
            textField.textColor = UIColor.cerise.title
            return textField
        }()

        private let disposeBag = DisposeBag()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            contentView.addSubview(textField)
            textField.cerise.layout { builder in
                builder.edges == contentView.cerise.edgesAnchor
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension EditorViewController {
    final class TextViewCell: UITableViewCell, Reusable {
        var textChanged: ControlEvent<String> {
            let source = textView.rx.text.orEmpty
                .map { $0.cerise.trimming(.whitespaceAndNewline) }
            return ControlEvent(events: source)
        }

        var textViewDidBeginEditing: ControlEvent<Void> {
            return textView.rx.didBeginEditing
        }

        var textViewDidEndEditing: ControlEvent<Void> {
            return textView.rx.didEndEditing
        }

        var textViewDidChangeAction: ((CGFloat) -> Void)?

        lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.textColor = UIColor.cerise.title
            return label
        }()

        private let textViewMinimumHeight: CGFloat = 30.0
        static let minimumHeight: CGFloat = 16 + 30 + 10 + 30 + 20

        lazy var textView: UITextView = {
            let textView = UITextView()
            textView.delegate = self
            textView.isScrollEnabled = false
            textView.textColor = UIColor.black
            textView.font = UIFont.systemFont(ofSize: 14.0)
            textView.textContainer.lineFragmentPadding = 0.0
            textView.textContainerInset = UIEdgeInsets.zero
            textView.autocapitalizationType = .none
            textView.autocorrectionType = .no
            textView.spellCheckingType = .no
            return textView
        }()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            textLabel?.textColor = UIColor.cerise.title
            contentView.addSubview(titleLabel)
            titleLabel.cerise.layout { builder in
                builder.top == contentView.topAnchor + 16
                builder.leading == contentView.leadingAnchor + 20
                builder.trailing == contentView.trailingAnchor - 20
                builder.height == 30
            }

            contentView.addSubview(textView)
            textView.cerise.layout { builder in
                builder.leading == titleLabel.leadingAnchor
                builder.trailing == titleLabel.trailingAnchor
                builder.top == titleLabel.bottomAnchor + 10
                builder.bottom == contentView.bottomAnchor - 20
                builder.height >= 30
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
extension EditorViewController.TextViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        //var bounds = textView.bounds
        //bounds.size = size
        //textView.bounds = bounds
        //textViewHeightConstraint.constant = max(textViewMinixumHeight, size.height)
        textViewDidChangeAction?(size.height + 80.0)
    }
}

extension EditorViewController {
    final class DatePickerCell: UITableViewCell, Reusable {
        static let datePickerTag = 99

        var datePicked: ControlEvent<Date> {
            return ControlEvent(events: datePicker.rx.date)
        }

        private(set) lazy var datePicker: UIDatePicker = {
            let datePicker = UIDatePicker()
            datePicker.tag = DatePickerCell.datePickerTag
            datePicker.datePickerMode = .date
            return datePicker
        }()

        private let disposeBag = DisposeBag()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            contentView.addSubview(datePicker)
            datePicker.cerise.layout { builder in
                builder.edges == contentView.cerise.edgesAnchor
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    final class DisclosureCell: UITableViewCell, Reusable {
        private(set) lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.textColor = UIColor.cerise.title
            return label
        }()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .value1, reuseIdentifier: reuseIdentifier)

            accessoryType = .disclosureIndicator
            textLabel?.textColor = UIColor.cerise.title
            detailTextLabel?.textColor = .white

            contentView.addSubview(titleLabel)
            titleLabel.cerise.layout { builder in
                builder.centerY == contentView.centerYAnchor
                builder.leading == contentView.leadingAnchor + 20
                builder.trailing == contentView.trailingAnchor - 20
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
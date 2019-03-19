//
//  EditorViewController.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/18.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class EditorViewController: BaseViewController {

    //var viewModel: NewMatterViewModel?

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.cerise.register(reusableCell: TextFieldCell.self)
        tableView.cerise.register(reusableCell: TextViewCell.self)
        tableView.cerise.register(reusableCell: DisclosureCell.self)
        tableView.cerise.register(reusableCell: DatePickerCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private enum Constant {
        static let pickerRowHeight: CGFloat = 200.0
        static let rowHeight: CGFloat = 56.0
    }

    private var notesRowHeight: CGFloat = 120.0
    private let generator = UISelectionFeedbackGenerator()

    private var pickedDate: Date = Date() {
        willSet {
            guard newValue != pickedDate else {
                return
            }

            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: Section.when.rawValue))
            cell?.detailTextLabel?.text = newValue.cerise.yearMonthDay
        }
        didSet {
            happenedDate.value = pickedDate as Date
        }
    }

    private var subject: Variable<String> = Variable("")
    private var tag: Variable<Tagble> = Variable(.none)
    private var datePickerIndexPath: IndexPath?
    private var happenedDate: Variable<Date> = Variable(Date())
    private var body: Variable<String> = Variable("")

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true

        view.addSubview(tableView)
        tableView.cerise.layout { builder in
            builder.edges == view.cerise.edgesAnchor
        }

        // MARK: Setup

        //let viewModel = self.viewModel ?? NewMatterViewModel()

//        cancelItem.rx.tap
//            .bind(to: viewModel.cancelAction)
//            .disposed(by: disposeBag)
//
//        postItem.rx.tap
//            .bind(to: viewModel.postAction)
//            .disposed(by: disposeBag)
//
//        viewModel.postButtonEnabled
//            .drive(self.postItem.rx.isEnabled)
//            .disposed(by: disposeBag)
//
//        viewModel.dismissViewController
//            .drive(onNext: { [weak self] in
//                self?.view.endEditing(true)
//                self?.dismiss(animated: true, completion: nil)
//            })
//            .disposed(by: disposeBag)
//
//        subject.asObservable()
//            .bind(to: viewModel.title)
//            .disposed(by: disposeBag)
//
//        tag.asObservable()
//            .bind(to: viewModel.tag)
//            .disposed(by: disposeBag)
//
//        happenedDate.asObservable()
//            .bind(to: viewModel.happenedAt)
//            .disposed(by: disposeBag)
//
//        body.asObservable()
//            .bind(to: viewModel.body)
//            .disposed(by: disposeBag)

        generator.prepare()
    }

    // MARK: Picker

    private func hasInlineDatePicker() -> Bool {
        return datePickerIndexPath != nil
    }

    private func indexPathHasPicker(_ indexPath: IndexPath) -> Bool {
        return (hasInlineDatePicker() && datePickerIndexPath?.row == indexPath.row)
    }

    private func hasPicker(for indexPath: IndexPath) -> Bool {
        let targetedRow = indexPath.row + 1
        let checkDatePickerCell = tableView.cellForRow(at: IndexPath(row: targetedRow, section: indexPath.section))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(DatePickerCell.datePickerTag) as? UIDatePicker
        return (checkDatePicker != nil)
    }

    private func toggleDatePicker(for selectedIndexPath: IndexPath) {
        tableView.beginUpdates()
        // date picker index path
        let indexPaths = [IndexPath(row: selectedIndexPath.row + 1, section: selectedIndexPath.section)]
        // check if 'indexPath' has an attached date picker below it
        if hasPicker(for: selectedIndexPath) {
            // found a picker below it, so remove it
            tableView.deleteRows(at: indexPaths, with: .fade)
            datePickerIndexPath = nil
        } else {
            // didn't find a picker below it, so we should insert it
            tableView.insertRows(at: indexPaths, with: .fade)
            datePickerIndexPath = indexPaths.first
        }
        tableView.endUpdates()
    }

    private func displayInlineDatePicker(for indexPath: IndexPath) {
        toggleDatePicker(for: indexPath)
    }

    private func hideInlineDatePicker() {
        guard hasInlineDatePicker(), let indexPath = datePickerIndexPath else {
            return
        }

        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        datePickerIndexPath = nil
        tableView.endUpdates()
    }
}

extension EditorViewController: UITableViewDataSource {
    private enum Section: Int, CaseIterable {
        case title = 0
        case when
        case notes

        var annotation: String {
            switch self {
            case .title:
                return "Title"
            case .when:
                return "Happen"
            case .notes:
                return "Notes"
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == Section.when.rawValue && hasInlineDatePicker()) ? 2 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Negative section: \(indexPath.section)")
        }

        switch section {
        case .title:
            let cell: TextFieldCell = tableView.cerise.dequeueReusableCell(for: indexPath)
            cell.textField.placeholder = "What's the Matter"
            cell.textChanged
                .bind(to: self.subject)
                .disposed(by: cell.rx.prepareForReuseBag)

            cell.textFieldDidBeginEditing
                .subscribe(onNext: { [weak self] in
                    self?.hideInlineDatePicker()
                })
                .disposed(by: cell.rx.prepareForReuseBag)
            return cell
        case .notes:
            let cell: TextViewCell = tableView.cerise.dequeueReusableCell(for: indexPath)
            cell.titleLabel.text = section.annotation

            cell.textViewDidBeginEditing
                .subscribe(onNext: { [weak self] in
                    self?.hideInlineDatePicker()
                })
                .disposed(by: cell.rx.prepareForReuseBag)

            cell.textViewDidChangeAction = { [unowned self] height in
                if height != self.notesRowHeight && height >= 120 {
                    tableView.beginUpdates()
                    self.notesRowHeight = height
                    tableView.endUpdates()
                    // scroll to bottom
                    //tableView.hi.scrollToBottom()
                    //(tableView as! TPKeyboardAvoidingTableView).tpKeyboardAvoiding_scrollToActiveTextField()
                }
            }

            cell.textViewDidEndEditing
                .withLatestFrom(cell.textView.rx.text.orEmpty)
                .map { $0.cerise.trimming(.whitespaceAndNewline) }
                .bind(to: body)
                .disposed(by: cell.rx.prepareForReuseBag)

            cell.textChanged
                .bind(to: body)
                .disposed(by: cell.rx.prepareForReuseBag)

            return cell
        case .when:
            if indexPathHasPicker(indexPath) {
                let cell: DatePickerCell = tableView.cerise.dequeueReusableCell(for: indexPath)
                cell.datePicked
                    .subscribe(onNext: { [weak self] date in
                        self?.pickedDate = date
                    })
                    .disposed(by: cell.rx.prepareForReuseBag)
                return cell
            } else {
                let cell: DisclosureCell = tableView.cerise.dequeueReusableCell(for: indexPath)
                cell.titleLabel.text = section.annotation
                cell.detailTextLabel?.text = pickedDate.cerise.yearMonthDay
                cell.detailTextLabel?.textColor = UIColor.gray
                return cell
            }
        }
    }
}

extension EditorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        // Selected date cell
        if indexPath.section == Section.when.rawValue && indexPath.row == 0 {
            view.endEditing(true)
            // show date picker
            displayInlineDatePicker(for: indexPath)
        } else {
            hideInlineDatePicker()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == datePickerIndexPath {
            return Constant.pickerRowHeight
        } else {
            return indexPath.section == Section.notes.rawValue ? notesRowHeight : Constant.rowHeight
        }
    }
}

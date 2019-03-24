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
import Keldeo

final class EditorViewController: BaseViewController {
    let viewModel: EditorViewModelType

    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.cerise.register(reusableCell: TextFieldCell.self)
        tableView.cerise.register(reusableCell: TagPickerCell.self)
        tableView.cerise.register(reusableCell: DisclosureCell.self)
        tableView.cerise.register(reusableCell: DatePickerCell.self)
        tableView.cerise.register(reusableCell: TextViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.separatorColor = UIColor(named: "BK20")
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()

    private enum Constant {
        static let pickerRowHeight: CGFloat = 200.0
        static let rowHeight: CGFloat = 56.0
        static let minimumNotesRowHeight: CGFloat = 120.0
    }

    private var notesRowHeight: CGFloat = Constant.minimumNotesRowHeight
    private var datePickerIndexPath: IndexPath?

    init(viewModel: EditorViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.cerise.layout { builder in
            builder.top == view.topAnchor + 40
            builder.leading == view.leadingAnchor
            builder.trailing == view.trailingAnchor
            builder.bottom == view.bottomAnchor
        }

        // MARK: ViewModel binding

        viewModel.outputs.itemsUpdated
            .subscribe(onNext: { [weak self] update in
                update.performUpdate(to: self?.tableView)
            })
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let titleIndexPath = IndexPath(row: EditorViewModel.Section.title.rawValue, section: 0)
        let titleCell = tableView.cellForRow(at: titleIndexPath) as? TextFieldCell
        titleCell?.textField.becomeFirstResponder()
    }
}

// MARK: - Picker

extension EditorViewController {
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

// MARK: - UITableViewDataSource

extension EditorViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return EditorViewModel.Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == EditorViewModel.Section.when.rawValue && hasInlineDatePicker()) ? 2 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = EditorViewModel.Section(rawValue: indexPath.section) else {
            fatalError("Negative section: \(indexPath.section)")
        }

        switch section {
        case .title:
            let cell: TextFieldCell = tableView.cerise.dequeueReusableCell(for: indexPath)
            cell.textField.attributedPlaceholder = NSAttributedString(string: "What's the Matter", attributes: [.foregroundColor: UIColor(named: "BK30") ?? .gray])
            cell.textChanged
                .bind(to: viewModel.title)
                .disposed(by: cell.rx.prepareForReuseBag)

            cell.textFieldDidBeginEditing
                .do(onNext: { _ in
                    HapticGenerator.trigger(with: .selection)
                })
                .subscribe(onNext: { [weak self] in
                    self?.hideInlineDatePicker()
                })
                .disposed(by: cell.rx.prepareForReuseBag)
            return cell
        case .tag:
            let cell: TagPickerCell = tableView.cerise.dequeueReusableCell(for: indexPath)
            cell.titleLabel.text = section.annotation
            cell.tagPicked
                .do(onNext: { [weak self] _ in
                    self?.hideInlineDatePicker()
                    self?.view.endEditing(true)
                })
                .distinctUntilChanged()
                .do(onNext: { _ in
                    HapticGenerator.trigger(with: .selection)
                })
                .bind(to: viewModel.tag)
                .disposed(by: cell.rx.prepareForReuseBag)
            return cell
        case .notes:
            let cell: TextViewCell = tableView.cerise.dequeueReusableCell(for: indexPath)
            cell.titleLabel.text = section.annotation

            let keyboardWillShow = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
                .filter { _ in UIApplication.shared.applicationState == .active }
                .map { $0.cerise.animation }
                .filterNil()

            Observable<Notification.KeyboardAnimation>.zip(keyboardWillShow, cell.textViewDidBeginEditing) { animation, _ in animation }
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { animation in
                    UIView.animate(
                        withDuration: animation.duration,
                        delay: 0, options: UIView.AnimationOptions(rawValue: animation.options),
                        animations: {
                            tableView.contentInset.bottom = animation.frame.height + 46
                        },
                        completion: { _ in
                            tableView.cerise.scrollToBottom(animated: true)
                        }
                    )
                })
                .disposed(by: cell.rx.prepareForReuseBag)

            cell.textViewDidBeginEditing
                .do(onNext: { _ in
                    HapticGenerator.trigger(with: .selection)
                })
                .subscribe(onNext: { [weak self] in
                    self?.hideInlineDatePicker()
                })
                .disposed(by: cell.rx.prepareForReuseBag)

            cell.textViewDidChangeAction = { [unowned self] height in
                if height != self.notesRowHeight && height >= Constant.minimumNotesRowHeight {
                    tableView.bounces = false
                    tableView.beginUpdates()
                    self.notesRowHeight = height
                    tableView.endUpdates()
                    tableView.bounces = true
                }
            }

            let keyboardWillHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
                .filter { _ in UIApplication.shared.applicationState == .active }
                .map { $0.cerise.animation }
                .filterNil()

            Observable<Notification.KeyboardAnimation>.zip(keyboardWillHide, cell.textViewDidEndEditing) { animation, _ in animation }
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { animation in
                    UIView.animate(
                        withDuration: animation.duration,
                        delay: 0, options: UIView.AnimationOptions(rawValue: animation.options),
                        animations: {
                            tableView.contentInset.bottom = 0
                            Log.d("keyboard height: \(animation.frame.height)")
                        },
                        completion: { _ in
                            tableView.cerise.scrollToTop(animated: true)
                        }
                    )
                })
                .disposed(by: cell.rx.prepareForReuseBag)

            cell.textViewDidEndEditing
                .withLatestFrom(cell.textView.rx.text.orEmpty)
                .map { $0.cerise.trimming(.whitespaceAndNewline) }
                .bind(to: viewModel.notes)
                .disposed(by: cell.rx.prepareForReuseBag)

            cell.textChanged
                .bind(to: viewModel.notes)
                .disposed(by: cell.rx.prepareForReuseBag)

            return cell
        case .when:
            if indexPathHasPicker(indexPath) {
                let cell: DatePickerCell = tableView.cerise.dequeueReusableCell(for: indexPath)
                cell.datePicked
                    .distinctUntilChanged()
                    .bind(to: viewModel.when)
                    .disposed(by: cell.rx.prepareForReuseBag)
                return cell
            } else {
                let cell: DisclosureCell = tableView.cerise.dequeueReusableCell(for: indexPath)
                cell.titleLabel.text = section.annotation
                cell.detailTextLabel?.text = viewModel.when.value.cerise.yearMonthDay
                return cell
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension EditorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        guard let section = EditorViewModel.Section(rawValue: indexPath.section) else {
            return
        }

        switch section {
        case .title:
            hideInlineDatePicker()
        case .tag:
            view.endEditing(true)
            hideInlineDatePicker()
        case .when:
            if indexPath.row == 0 {
                view.endEditing(true)
                HapticGenerator.trigger(with: .selection)
                // show date picker
                displayInlineDatePicker(for: indexPath)
            } else {
                hideInlineDatePicker()
            }
        case .notes:
            hideInlineDatePicker()

            let notesCell = tableView.cellForRow(at: indexPath) as? TextViewCell
            notesCell?.textView.becomeFirstResponder()
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.cerise.dark

        guard indexPath.section == EditorViewModel.Section.tag.rawValue,
            let tagPickerCell = cell as? TagPickerCell else {
            return
        }

        DispatchQueue.main.async {
            tagPickerCell.setTag(self.viewModel.tag.value, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == datePickerIndexPath {
            return Constant.pickerRowHeight
        } else {
            return indexPath.section == EditorViewModel.Section.notes.rawValue ? notesRowHeight : Constant.rowHeight
        }
    }
}

extension Notification: CeriseCompatible {
    typealias KeyboardAnimation = (frame: CGRect, duration: TimeInterval, options: UInt)
}

extension Cerise where Base == Notification {

    var animation: Notification.KeyboardAnimation? {
        guard let frame = base.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let animationDuration = base.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let animationCurve = base.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
                return nil
        }
        return (frame: frame, duration: animationDuration, options: animationCurve)
    }
}

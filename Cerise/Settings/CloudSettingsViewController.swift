//
//  CloudSettingsViewController.swift
//  Cerise
//
//  Created by alex.huo on 2019/9/21.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CloudSettingsViewController: BaseViewController {

    private var attemptToDismiss = PublishRelay<Void>()
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.cerise.register(reusableCell: ToggleCell.self)
        tableView.rowHeight = Constant.rowHeight
        tableView.estimatedRowHeight = Constant.rowHeight
        tableView.sectionHeaderHeight = Constant.sectionHeaderHeight
        tableView.sectionFooterHeight = Constant.sectionFooterHeight
        tableView.backgroundColor = .clear
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorColor = UIColor(named: "BK20")
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.tableFooterView = FooterView()
        return tableView
    }()

    private enum Constant {
        static let rowHeight: CGFloat = 56.0
        static let sectionHeaderHeight: CGFloat = 64.0
        static let sectionFooterHeight: CGFloat = 32.0
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)

        transitioningDelegate = self
        modalPresentationStyle = .custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.cerise.dark
        view.addSubview(tableView)
        tableView.cerise.layout { builder in
            builder.edges == view.cerise.edgesAnchor
        }

        attemptToDismiss
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        let items = BehaviorRelay(value: [NSLocalizedString("iCloud Backup", comment: "icloud backup title")])
        items
            .bind(to: tableView.rx.items(cellIdentifier: ToggleCell.reuseIdentifier, cellType: ToggleCell.self)) { _, modal, cell in
                cell.textLabel?.text = modal
                cell.toggle.rx.isOn
                    .skip(1)
                    .map { $0 ? Preferences.Cloud.enabled : Preferences.Cloud.disabled }
                    .bind(to: Preferences.cloud)
                    .disposed(by: cell.reusableBag)
            }
            .disposed(by: disposeBag)

        rx.viewDidAppear
            .take(1)
            .flatMap { _ -> Observable<Bool> in
                Observable.create { observer -> Disposable in
                    DispatchQueue.global().async {
                        observer.onNext(Cloud.shared.isAvailable())
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak tableView] available in
                let cell = tableView?.visibleCells.first as? ToggleCell
                cell?.toggle.isEnabled = available
            })
            .filter { $0 }
            .map { _ in Preferences.cloud.value.isEnabled }
            .subscribe(onNext: { [weak tableView] enabled in
                let cell = tableView?.visibleCells.first as? ToggleCell
                cell?.toggle.setOn(enabled, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension CloudSettingsViewController {
    class ToggleCell: RxTableViewCell, Reusable {
        lazy var toggle: UISwitch = {
            let toggle = UISwitch()
            toggle.isOn = false
            toggle.tintColor = UIColor.cerise.tint
            toggle.onTintColor = UIColor.cerise.tint
            return toggle
        }()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            selectionStyle = .none
            backgroundColor = UIColor.cerise.darkContent
            contentView.backgroundColor = UIColor.cerise.darkContent
            textLabel?.textColor = .white
            textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
            tintColor = UIColor.cerise.tint

            accessoryType = .none
            accessoryView = toggle
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class FooterView: UIView {
        lazy var backupButton: UIButton = {
            let button = UIButton(type: .custom)
            button.setTitle(NSLocalizedString("Backup Now", comment: "Backup now button title"), for: .normal)
            button.setTitleColor(UIColor.cerise.title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            button.isHidden = true
            return button
        }()

        override init(frame: CGRect) {
            super.init(frame: frame)

            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            label.text = NSLocalizedString("Automatically back up your matters.", comment: "Backup descriptions")
            label.textColor = UIColor.cerise.description
            label.numberOfLines = 0

            addSubview(label)
            label.cerise.layout { builder in
                builder.centerX == self.centerXAnchor
                builder.top == self.topAnchor
            }

            addSubview(backupButton)
            backupButton.cerise.layout { builder in
                builder.centerX == self.centerXAnchor
                builder.top == label.bottomAnchor + 8
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension CloudSettingsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        guard presented == self else {
            return nil
        }

        let presentationController = ModalPresentationController(presentedViewController: presented,
                                                                 presenting: presenting)
        let bounds = UIApplication.shared.keyWindow?.bounds ?? UIScreen.main.bounds
        presentationController.preferredContentHeight = (bounds.height / 5 * 2).rounded(.up) + 42
        presentationController.setContentScrollView(tableView)
        presentationController.handleView.backgroundColor = UIColor.cerise.tint
        presentationController.bottomView.backgroundColor = UIColor.cerise.dark
        presentationController.attemptToDismiss
            .bind(to: attemptToDismiss)
            .disposed(by: disposeBag)
        return presentationController
    }
}

//
//  SettingsViewController.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/4/5.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class SettingsViewController: BaseViewController {

    private var attemptToDismiss = PublishRelay<Void>()
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.cerise.register(reusableCell: CheckmarkCell.self)
        tableView.rowHeight = Constant.rowHeight
        tableView.estimatedRowHeight = Constant.rowHeight
        tableView.sectionHeaderHeight = Constant.sectionHeaderHeight
        tableView.sectionFooterHeight = Constant.sectionFooterHeight
        tableView.backgroundColor = .clear
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorColor = UIColor(named: "BK20")
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.tableFooterView = self.footerView
        return tableView
    }()

    private lazy var footerView: FooterView = {
        let view = FooterView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: Constant.footerViewHeight)))
        return view
    }()

    private enum Constant {
        static let rowHeight: CGFloat = 56.0
        static let sectionHeaderHeight: CGFloat = 64.0
        static let sectionFooterHeight: CGFloat = 32.0
        static let footerViewHeight: CGFloat = 88.0
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

        HapticGenerator.trigger(with: .impactLight)
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

        let items = BehaviorRelay(value: Preferences.Accessibility.allCases)
        items
            .bind(to: tableView.rx.items(cellIdentifier: CheckmarkCell.reuseIdentifier, cellType: CheckmarkCell.self)) { _, modal, cell in
                cell.textLabel?.text = modal.title
            }
            .disposed(by: disposeBag)

        tableView.rx
            .modelSelected(Preferences.Accessibility.self)
            .bind(to: Preferences.accessibility)
            .disposed(by: disposeBag)

        tableView.rx
            .itemSelected
            .observeOn(MainScheduler.asyncInstance)
            .do(onNext: { _ in
                HapticGenerator.trigger(with: .selection)
            })
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        rx.viewDidAppear
            .take(1)
            .compactMap { _ in items.value.firstIndex(of: Preferences.accessibility.value) }
            .map { IndexPath(row: $0, section: 0) }
            .subscribe(onNext: { [weak tableView] indexPath in
                tableView?.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            })
            .disposed(by: disposeBag)

        footerView.backupButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                let vc = CloudSettingsViewController()
                self.present(vc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

extension SettingsViewController {
    class CheckmarkCell: RxTableViewCell, Reusable {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            selectionStyle = .none
            backgroundColor = UIColor.cerise.darkContent
            contentView.backgroundColor = UIColor.cerise.darkContent
            textLabel?.textColor = .white
            textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
            tintColor = UIColor.cerise.tint
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)

            if selected {
                accessoryType = .checkmark
            } else {
                accessoryType = .none
            }
        }
    }

    class FooterView: UIView {
        lazy var backupButton: UIButton = {
            let button = UIButton(type: .custom)
            button.setTitle(NSLocalizedString("☁️ Backup", comment: "icloud backup"), for: .normal)
            button.setTitleColor(UIColor.cerise.title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            return button
        }()

        override init(frame: CGRect) {
            super.init(frame: frame)

            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            label.text = NSLocalizedString("📱 -> Settings -> Cerise -> Accessibility", comment: "App settings guide")
            label.textColor = UIColor.cerise.description

            addSubview(label)
            label.cerise.layout { builder in
                builder.centerX == self.centerXAnchor
                builder.top == self.topAnchor
            }

            addSubview(backupButton)
            backupButton.cerise.layout { builder in
                builder.centerX == self.centerXAnchor
                builder.top == label.bottomAnchor + 20
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension SettingsViewController: UIViewControllerTransitioningDelegate {
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

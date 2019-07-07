//
//  MattersViewController.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 9/10/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class MattersViewController: BaseViewController {
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.cerise.register(reusableCell: MatterCell.self)
        tableView.rowHeight = Constant.rowHeight
        tableView.estimatedRowHeight = Constant.rowHeight
        tableView.sectionHeaderHeight = Constant.sectionHeaderHeight
        tableView.sectionFooterHeight = Constant.sectionFooterHeight
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        return tableView
    }()

    let viewModel: MattersViewModelType

    private var anchorIndexPath: IndexPath?

    private enum Constant {
        static let rowHeight: CGFloat = 68.0
        static let sectionHeaderHeight: CGFloat = 44.0
        static let sectionFooterHeight: CGFloat = 32.0
    }

    init(viewModel: MattersViewModelType = MattersViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Matters"
        registerForPreviewing(with: self, sourceView: tableView)

        view.addSubview(tableView)
        tableView.cerise.layout { builder in
            builder.edges == view.cerise.edgesAnchor
        }

        let refreshControl = CherryRefreshControl()
        refreshControl.tintColor = UIColor.gray.withAlphaComponent(0.16)
        tableView.refreshControl = refreshControl

        // MARK: ViewModel outputs binding

        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.inputs.addAction)
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            .map { _ in () }
            .bind(to: viewModel.inputs.refresh)
            .disposed(by: disposeBag)

        viewModel.outputs.showMatterDetail
            .do(onNext: { _ in
                HapticGenerator.trigger(with: .impact)
            })
            .subscribe(onNext: { [unowned self] matter in
                let vc = MatterViewController(viewModel: MatterViewModel(matter: matter))
                vc.transitioningDelegate = self
                vc.modalPresentationStyle = .currentContext
                self.present(vc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.addNewMatter
            .observeOn(MainScheduler.instance)
            .do(onNext: { [unowned self] in
                HapticGenerator.trigger(with: .impact)
                self.tableView.refreshControl?.endRefreshing()
            })
            .delay(.milliseconds(Int(0.25 * 1_000.0)), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                let vc = ComposerViewController()
                self.present(vc, animated: true)
            })
            .disposed(by: disposeBag)

        let dataSource = RxTableViewSectionedReloadDataSource<MattersViewSection>(configureCell: { _, tableView, indexPath, viewModel in
            let cell: MatterCell = tableView.cerise.dequeueReusableCell(for: indexPath)
            cell.bind(with: viewModel)
            return cell
        })

        viewModel.outputs.sections
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        viewModel.outputs.itemDeselected
            .do(onNext: { [unowned self] indexPath in
                self.anchorIndexPath = indexPath
            })
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)

        tableView.rx.itemDeleted
            .bind(to: viewModel.inputs.itemDeleted)
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .bind(to: viewModel.inputs.itemSelected)
            .disposed(by: disposeBag)

        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource[index]
            return section.model.title
        }

        dataSource.titleForFooterInSection = { dataSource, section in
            let section = dataSource[section]
            return section.model.footer
        }

        dataSource.canEditRowAtIndexPath = { _, _ in
            return true
        }
    }
}

// MARK: - UIViewControllerPreviewingDelegate

extension MattersViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        viewControllerToCommit.transitioningDelegate = self
        viewControllerToCommit.modalPresentationStyle = .currentContext
        present(viewControllerToCommit, animated: true, completion: nil)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location),
            let matter = viewModel.matter(at: indexPath) else {
            return nil
        }

        anchorIndexPath = indexPath
        let viewController = MatterViewController(viewModel: MatterViewModel(matter: matter))
        let cellRect = tableView.rectForRow(at: indexPath)
        previewingContext.sourceRect = previewingContext.sourceView.convert(cellRect, from: tableView)

        return viewController
    }
}

// MARK: - CherryTransitioning

extension MattersViewController: CherryTransitioning {
    var anchorView: UIView? {
        return anchorIndexPath.flatMap { tableView.cellForRow(at: $0)?.contentView }
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension MattersViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CherryTransitionController(duration: 0.45, operation: .forward)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CherryTransitionController(duration: 0.45, operation: .backward)
    }
}

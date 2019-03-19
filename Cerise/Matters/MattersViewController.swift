////
////  MattersViewController.swift
////  Cerise
////
////  Created by bl4ckra1sond3tre on 9/10/16.
////  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
////
//
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
//import WatchConnectivity

final class MattersViewController: BaseViewController {
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.cerise.register(reusableCell: MattersViewController.MatterCell.self)
        tableView.rowHeight = Constant.rowHeight
        tableView.estimatedRowHeight = Constant.rowHeight
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        return tableView
    }()

    private var viewModel: MattersViewModelType

    private enum Constant {
        static let rowHeight: CGFloat = 64.0
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

        //WatchSessionService.shared.start(withDelegate: self)
        registerForPreviewing(with: self, sourceView: tableView)

        view.addSubview(tableView)
        tableView.cerise.layout { builder in
            builder.edges == view.cerise.edgesAnchor
        }

        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl

        // MARK: ViewModel outputs binding

        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.inputs.addAction)
            .disposed(by: disposeBag)

        viewModel.outputs.showMatterDetail
            .do(onNext: { _ in
                HapticGenerator.trigger(with: .impact)
            })
            .subscribe(onNext: { [unowned self] matter in
                let vc = MatterViewController()
                vc.viewModel = MatterViewModel(matter: matter)
                self.present(vc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.addNewMatter
            .do(onNext: { [unowned self] in
                HapticGenerator.trigger(with: .impact)
                self.tableView.refreshControl?.endRefreshing()
            })
            .subscribe(onNext: { [unowned self] in
                let vc = ComposerViewController()
                self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
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
            return section.model
        }

        dataSource.canEditRowAtIndexPath = { _, _ in
            return true
        }
    }
}

// MARK: - UIViewControllerPreviewingDelegate

extension MattersViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit, animated: true, completion: nil)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location),
            let matter = viewModel.matter(at: indexPath) else {
            return nil
        }

        let viewController = MatterViewController()
        viewController.viewModel = MatterViewModel(matter: matter)
        let cellRect = tableView.rectForRow(at: indexPath)
        previewingContext.sourceRect = previewingContext.sourceView.convert(cellRect, from: tableView)

        return viewController
    }
}

//extension MattersViewController: WCSessionDelegate {
//
//    func session(_ session: WCSession,
//                 activationDidCompleteWith activationState: WCSessionActivationState,
//                 error: Error?) {
//        Defaults.watchState.value = activationState.rawValue
//    }
//
//    func sessionDidBecomeInactive(_ session: WCSession) {
//    }
//
//    func sessionDidDeactivate(_ session: WCSession) {
//    }
//}

enum WatchState: Int {
    case notActivated
    case inactive
    case activated
    case notInstalled
    case unpaired

    var name: String {
        switch self {
        case .notActivated:
            return "not activated"
        case .inactive:
            return "inactive"
        case .activated:
            return "activated"
        case .notInstalled:
            return "not installed"
        case .unpaired:
            return "unpaired"
        }
    }
}

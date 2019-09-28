//
//  CloudBackupViewController.swift
//  Cerise
//
//  Created by alex.huo on 2019/9/21.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Keldeo

final class CloudBackupViewController: BaseViewController {

    private var attemptToDismiss = PublishRelay<Void>()

    private(set) lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = UIColor(named: "BK80")
        button.setImage(UIImage(named: "Close")?.withRenderingMode(.alwaysTemplate), for: .normal)
        return button
    }()

    private(set) lazy var cloudView: CloudView = {
        return CloudView(frame: .zero)
    }()

    private enum Constant {
        static let padding: CGFloat = 13.0
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        transitioningDelegate = self
        modalPresentationStyle = .custom
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.cerise.dark
        view.addSubview(cloudView)
        view.addSubview(closeButton)

        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        cloudView.backupButton.rx.tap
            .subscribe(onNext: {
                self.backupInBackground()
            })
            .disposed(by: disposeBag)

        closeButton.cerise.layout { builder in
            builder.top == view.topAnchor + 8
            builder.trailing == view.trailingAnchor - 8
            builder.size == CGSize(width: 44, height: 44)
        }

        cloudView.cerise.layout { builder in
            builder.edges == view.cerise.edgesAnchor
        }

        let fittingSize = CGSize(width: view.bounds.width - Constant.padding * 2, height: .greatestFiniteMagnitude)
        let contentSize = cloudView.systemLayoutSizeFitting(fittingSize,
                                                            withHorizontalFittingPriority: .required,
                                                            verticalFittingPriority: .fittingSizeLevel)

        preferredContentSize = CGSize(width: contentSize.width, height: contentSize.height + Constant.padding)
    }

    private func backupInBackground() {
        Preferences.cloud.accept(.enabled)
        cloudView.activityView.startAnimating()

        DispatchQueue.global().async {
            self.backup()
            DispatchQueue.main.async {
                self.cloudView.activityView.stopAnimating()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    private func backup() {
        do {
            let cloud = Cloud.shared
            let urls = try Charmander().urls()
            urls.forEach { url in
                try? cloud.copyItem(at: url)
            }
        } catch {
            Log.e("Backup failed: \(error)")
        }
    }
}

extension CloudBackupViewController {
    class CloudView: UIView {
        lazy var backupButton: UIButton = {
            let backupButton = UIButton(type: .custom)
            backupButton.setTitle(NSLocalizedString("Backup", comment: "Back up button title"), for: .normal)
            backupButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            backupButton.layer.cornerRadius = 25
            backupButton.setTitleColor(UIColor.white, for: .normal)
            backupButton.setBackgroundImage(UIImage(color: UIColor.cerise.tint), for: .normal)
            backupButton.layer.masksToBounds = true
            return backupButton
        }()

        lazy var activityView: UIActivityIndicatorView = {
            let view = UIActivityIndicatorView(style: .gray)
            view.isHidden = true
            view.hidesWhenStopped = true
            return view
        }()

        override init(frame: CGRect) {
            super.init(frame: frame)

            let titleLabel = UILabel()
            titleLabel.text = NSLocalizedString("iCloud Back Up", comment: "iCloud back up title")
            titleLabel.textColor = .white
            titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)

            let detailsLabel = UILabel()
            detailsLabel.text = NSLocalizedString("Back up your matters to iCloud.", comment: "iCloud backup details")
            detailsLabel.textColor = UIColor.cerise.lightText
            detailsLabel.numberOfLines = 0
            detailsLabel.textAlignment = .center
            detailsLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)

            let cloudLabel = UILabel()
            cloudLabel.text = "☁️"
            cloudLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)

            addSubview(titleLabel)
            addSubview(detailsLabel)
            addSubview(cloudLabel)
            addSubview(backupButton)
            addSubview(activityView)

            titleLabel.cerise.layout { builder in
                builder.top == topAnchor + 24
                builder.centerX == centerXAnchor
            }

            detailsLabel.cerise.layout { builder in
                builder.top == titleLabel.bottomAnchor + 8
                builder.leading == leadingAnchor + 24
                builder.trailing == trailingAnchor - 24
            }

            cloudLabel.cerise.layout { builder in
                builder.top == detailsLabel.bottomAnchor + 24
                builder.centerX == centerXAnchor
            }

            backupButton.cerise.layout { builder in
                builder.top == cloudLabel.bottomAnchor + 24
                builder.bottom == bottomAnchor - 24
                builder.height == 50.0
                builder.leading == leadingAnchor + 30
                builder.trailing == trailingAnchor - 30
            }

            activityView.cerise.layout { builder in
                builder.center == backupButton.cerise.centerAnchor
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension CloudBackupViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = PanelPresentationController(presentedViewController: presented,
                                                                 presenting: presenting)
        presentationController.contentInset = UIEdgeInsets(top: 0,
                                                           left: Constant.padding,
                                                           bottom: Constant.padding,
                                                           right: Constant.padding)
        return presentationController
    }
}

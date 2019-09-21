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

final class CloudBackupViewController: BaseViewController {

    private var attemptToDismiss = PublishRelay<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleLabel = UILabel()
        titleLabel.text = "iCloud Back Up"
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)

        let detailsLabel = UILabel()
        detailsLabel.text = "Back up your matters to iCloud."
        detailsLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)

        let cloudLabel = UILabel()
        cloudLabel.text = "☁️"
        cloudLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)

        let backupButton = UIButton(type: .custom)
        backupButton.setTitle("Backup", for: .normal)
        backupButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
    }
}

extension CloudBackupViewController: UIViewControllerTransitioningDelegate {
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
        presentationController.handleView.backgroundColor = UIColor.cerise.tint
        presentationController.bottomView.backgroundColor = UIColor.cerise.dark
        presentationController.attemptToDismiss
            .bind(to: attemptToDismiss)
            .disposed(by: disposeBag)
        return presentationController
    }
}

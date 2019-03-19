//
//  MatterViewController.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
//import RxSwift
//import RxCocoa
//import RxDataSources
//
final class MatterViewController: BaseViewController {
    private(set) lazy var whenLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.cerise.tint
        label.textAlignment = .center
        return label
    }()

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private(set) lazy var notesTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 12.0, left: 8.0, bottom: 12.0, right: 8.0)
        textView.textColor = .white
        textView.backgroundColor = UIColor(named: "BK10")
        textView.keyboardDismissMode = .interactive
        textView.keyboardAppearance = .dark
        textView.isEditable = false
        return textView
    }()

    var viewModel: MatterViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        registerForPreviewing(with: self, sourceView: view)

        let contentView = UIView()
        contentView.backgroundColor = .black
        view.addSubview(contentView)
        contentView.cerise.layout { builder in
            builder.top == view.safeAreaLayoutGuide.topAnchor
            builder.leading == view.leadingAnchor
            builder.trailing == view.trailingAnchor
            builder.height == 300
        }

        contentView.addSubview(titleLabel)
        titleLabel.cerise.layout { builder in
            builder.leading == contentView.leadingAnchor + 24
            builder.trailing == contentView.trailingAnchor - 24
            builder.centerY == contentView.centerYAnchor
        }

        contentView.addSubview(whenLabel)
        whenLabel.cerise.layout { builder in
            builder.bottom == contentView.bottomAnchor - 8
            builder.centerX == contentView.centerXAnchor
        }

        view.addSubview(notesTextView)
        notesTextView.cerise.layout { builder in
            builder.leading == contentView.leadingAnchor
            builder.trailing == contentView.trailingAnchor
            builder.top == contentView.bottomAnchor
            builder.bottom == view.bottomAnchor
        }

        guard let viewModel = viewModel else {
            return
        }

        configure(with: viewModel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        if let userInfo = userActivity?.userInfo {
//            if let json = userInfo[Configuration.UserActivity.matterUserInfoKey] as? [String: Any], let sharedMatter = SharedMatter.with(json: json) {
//
//                let matter = Matter.from(sharedMatter)
//                self.viewModel = MatterViewModel(matter: matter)
//
//                if let viewModel = self.viewModel {
//                    configure(with: viewModel)
//                }
//            }
//        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        stopUserActivity()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    override func restoreUserActivityState(_ activity: NSUserActivity) {
        userActivity = activity

        super.restoreUserActivityState(activity)
    }

    override func updateUserActivityState(_ activity: NSUserActivity) {
        //activity.addUserInfoEntries(from: [Configuration.UserActivity.matterUserInfoKey: Matter.shared(with: matter).json])
        super.updateUserActivityState(activity)
    }
}

extension MatterViewController {
    private func configure(with viewModel: MatterViewModel) {
        viewModel.title
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)

         viewModel.when
             .drive(whenLabel.rx.text)
             .disposed(by: disposeBag)

        /*
         viewModel.notes
         .drive(notesTextView.rx.text)
         .disposed(by: disposeBag)

         viewModel.tag
         .drive(onNext: { [weak self] textColor in
         self?.titleLabel.textColor = textColor
         self?.whenLabel.textColor = textColor
         })
         .disposed(by: disposeBag)*/
    }

    private func startUserActivity() {
        //let activity = NSUserActivity(activityType: Configuration.UserActivity.watch)
        //activity.title = "Watch Matter"
        //activity.userInfo = [Configuration.UserActivity.matterUserInfoKey: Matter.shared(with: matter).json]

        //userActivity = activity
        userActivity?.becomeCurrent()
    }

    private func stopUserActivity() {
        userActivity?.invalidate()
    }
}

extension MatterViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        HapticGenerator.trigger(with: .impactHeavy)
        dismiss(animated: true, completion: nil)
        return nil
    }
}

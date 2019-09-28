//
//  MainViewController.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import Keldeo
import RxSwift

final class MainViewController: BaseViewController {
    private var containerView: UIView = UIView()

    private lazy var mattersViewController = MattersViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Cerise"
        view.backgroundColor = UIColor.black
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        let logoItem = UIBarButtonItem(image: UIImage(named: "Logo"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = logoItem

        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.rightBarButtonItem = addItem

        Preferences.accessibility
            .subscribe(onNext: { [weak navigationItem] style in
                switch style {
                case .normal:
                    navigationItem?.leftBarButtonItem = logoItem
                    navigationItem?.rightBarButtonItem = addItem
                case .modern:
                    navigationItem?.leftBarButtonItem = nil
                    navigationItem?.rightBarButtonItem = logoItem
                case .clean:
                    navigationItem?.leftBarButtonItem = nil
                    navigationItem?.rightBarButtonItem = nil
                }
            })
            .disposed(by: disposeBag)

        addChild(mattersViewController)
        view.addSubview(mattersViewController.view)
        mattersViewController.view.cerise.layout { builder in
            builder.edges == view.cerise.edgesAnchor
        }
        mattersViewController.didMove(toParent: self)

        logoItem.rx.tap
            .subscribe(onNext: { [weak self] in
                let vc = SettingsViewController()
                self?.present(vc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        addItem.rx.tap
            .bind(to: mattersViewController.viewModel.inputs.addAction)
            .disposed(by: disposeBag)

        // Check iCloud available
        let cloudKey = "com.cerise.backup.remind"
        rx.viewDidAppear
            .take(1)
            .flatMap { _ -> Observable<Bool> in
                Observable.create { observer -> Disposable in
                    DispatchQueue.global().async {
                        let booted = try? Charmander().urls().count > 2
                        observer.onNext(booted ?? false)
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .filter { $0 || UserDefaults.standard.bool(forKey: Charmander.firstMatterKey) }
            .flatMap { _ -> Observable<Bool> in
                Observable.create { observer -> Disposable in
                    DispatchQueue.global().async {
                        observer.onNext(Cloud.shared.isAvailable())
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .filter { $0 }
            .do(onNext: { available in
                Log.i("iCloud available: \(available)")
            })
            .filter { _ in !UserDefaults.standard.bool(forKey: cloudKey) }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { _ in
                let vc = CloudBackupViewController()
                self.present(vc, animated: true) {
                    UserDefaults.standard.set(true, forKey: cloudKey)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension MainViewController: CherryTransitioning {
    var anchorView: UIView? {
        return mattersViewController.anchorView
    }
}

extension MainViewController: RoutingCoordinatorDelegate {
    func coordinatorRepresentation() -> RoutingCoordinator.Representaion {
        return .present(from: self, animated: true)
    }
}

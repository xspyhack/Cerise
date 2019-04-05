//
//  UIScrollView+Refresh.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/4/5.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

private var refreshControlKey: Void = ()
private var disposeBagKey: Void = ()

final class RefreshControl: UIControl {
    let refreshIndicator: UIImageView

    private(set) var isRefreshing: Bool = false

    init() {
        refreshIndicator = UIImageView(image: UIImage(named: "DownArrow"))
        refreshIndicator.frame = CGRect(origin: .zero, size: CGSize(width: 80, height: 40))
        let frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        super.init(frame: frame)
        addSubview(refreshIndicator)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let superview = superview {
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: superview.bounds.width, height: frame.height)
        }

        refreshIndicator.center = convert(center, from: superview)
    }

    func beginRefreshing() {
        sendActions(for: .valueChanged)
    }

    func endRefreshing() {
        sendActions(for: .valueChanged)
    }
}

extension Reactive where Base: RefreshControl {
    var isRefreshing: Binder<Bool> {
        return Binder(self.base) { refreshControl, refresh in
            if refresh {
                refreshControl.beginRefreshing()
            } else {
                refreshControl.endRefreshing()
            }
        }
    }
}

extension Cerise where Base: UIScrollView {
    private(set) var refreshControl: RefreshControl? {
        get {
            return objc_getAssociatedObject(base, &refreshControlKey) as? RefreshControl
        }
        set {
            objc_setAssociatedObject(base, &refreshControlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var disposeBag: DisposeBag {
        get {
            return objc_getAssociatedObject(base, &disposeBagKey) as? DisposeBag ?? DisposeBag()
        }
        set {
            objc_setAssociatedObject(base, &disposeBagKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func addRefreshControl(_ refreshControl: RefreshControl) {
        if let oldRefreshControl = self.refreshControl {
            removeRefreshControl(oldRefreshControl)
        }

        self.refreshControl = refreshControl
        let refreshView = refreshControl
        let yOrigin = -refreshView.bounds.height
        refreshView.frame = CGRect(x: 0, y: yOrigin, width: base.bounds.width, height: refreshView.bounds.height)
        base.addSubview(refreshView)
        base.sendSubviewToBack(refreshView)

        base.rx.contentOffset
            .subscribe(onNext: { [weak self] offset in
                if offset.y > yOrigin {
                    self?.beginRefreshing()
                }
            })
            .disposed(by: disposeBag)
    }

    func removeRefreshControl(_ refreshControl: RefreshControl) {
        refreshControl.removeFromSuperview()
        disposeBag = DisposeBag()
    }

    func beginRefreshing() {
        refreshControl?.beginRefreshing()
    }

    func endRefreshing() {
        refreshControl?.endRefreshing()
    }
}

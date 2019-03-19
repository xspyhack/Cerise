//
//  UITableView+Rx.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 01/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UITableView {
    public func enablesAutoDeselect() -> Disposable {
        return itemSelected
            .map { (at: $0, animated: true) }
            .subscribe(onNext: base.deselectRow)
    }
}

extension Reactive where Base: UITableViewCell {
    var prepareForReuse: Observable<Void> {
        return Observable.of(base.rx.sentMessage(#selector(UITableViewCell.prepareForReuse)).map { _ in }, base.rx.deallocated).merge()
    }

    var prepareForReuseBag: DisposeBag {
        MainScheduler.ensureExecutingOnScheduler()

        if let bag = objc_getAssociatedObject(base, &_prepareForReuseBag) as? DisposeBag {
            return bag
        }

        let bag = DisposeBag()
        objc_setAssociatedObject(base, &_prepareForReuseBag, bag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)

        _ = self.base.rx.sentMessage(#selector(UITableViewCell.prepareForReuse))
            .subscribe(onNext: { [weak base] _ in
                let newBag = DisposeBag()
                objc_setAssociatedObject(base as Any, &_prepareForReuseBag, newBag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            })

        return bag
    }
}

private var _prepareForReuseBag: Void = ()

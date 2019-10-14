//
//  CherryRefreshControl.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/4/5.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class CherryRefreshControl: UIRefreshControl {

    private let disposeBag = DisposeBag()
    private var observeBag = DisposeBag()

    private(set) lazy var refreshIndicator: UIImageView = {
        let indicator = UIImageView(image: UIImage(named: "RefreshIndicator")?.withRenderingMode(.alwaysTemplate))
        indicator.tintColor = .white
        indicator.contentMode = .scaleAspectFit
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        refreshIndicator.frame = CGRect(origin: .zero, size: CGSize(width: 80, height: 20))
        addSubview(refreshIndicator)
    }

    override init() {
        super.init()

        refreshIndicator.frame = CGRect(origin: .zero, size: CGSize(width: 80, height: 20))
        addSubview(refreshIndicator)

        rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.refreshIndicator.tintColor = UIColor.cerise.tint
            })
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        guard let superview = superview as? UIScrollView else {
            return
        }

        let threshold: CGFloat = 20.0
        observeBag = DisposeBag()
        superview.rx.contentOffset
            .map { $0.y + superview.adjustedContentInset.top }
            .subscribe(onNext: { [weak self] offset in
                self?.refreshIndicator.alpha = (-offset) / (threshold * 3)
            })
            .disposed(by: observeBag)

        superview.rx.willBeginDragging
            .subscribe(onNext: { [weak self] _ in
                self?.refreshIndicator.tintColor = .white
            })
            .disposed(by: observeBag)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        refreshIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}

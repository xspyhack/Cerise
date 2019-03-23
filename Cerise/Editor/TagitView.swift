//
//  TagitView.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/22.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TagitView: UIView {
    let items = Tagble.allCases.shuffled()

    var itemSelected: ControlEvent<Tagble> {
        let source = collectionView.rx.itemSelected
            .map { [unowned self] in
                return self.items.safe[$0.item]
            }
            .filterNil()
        return ControlEvent(events: source)
    }

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.itemSize = CGSize(width: 44, height: 44)

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.cerise.register(reusableCell: ItemCell.self)

        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(collectionView)
        collectionView.cerise.layout { builder in
            builder.leading == leadingAnchor
            builder.trailing == trailingAnchor
            builder.centerY == centerYAnchor
            builder.height == 44.0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func select(tag: Tagble, animated: Bool) {
        guard let index = items.index(of: tag) else {
            return
        }

        collectionView.selectItem(at: IndexPath(item: index, section: 0),
                                  animated: animated,
                                  scrollPosition: .centeredHorizontally)
    }
}

extension TagitView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let tag = items.safe[indexPath.item] else {
            fatalError()
        }

        let cell: ItemCell = collectionView.cerise.dequeueReusableCell(for: indexPath)
        cell.itemColor = UIColor(hex: tag.rawValue)
        return cell
    }
}

extension TagitView: UICollectionViewDelegate {
}

extension TagitView {
    final class ItemCell: UICollectionViewCell, Reusable {
        var itemColor: UIColor = UIColor.clear {
            didSet {
                outerView.backgroundColor = itemColor
                innerView.backgroundColor = itemColor
            }
        }

        override var isSelected: Bool {
            didSet {
                gapView.isHidden = !isSelected
            }
        }

        private lazy var outerView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.white
            view.layer.cornerRadius = Constant.outerSize.width / 2.0
            return view
        }()

        private lazy var gapView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.cerise.dark
            view.layer.cornerRadius = Constant.gapSize.width / 2.0
            view.isHidden = true
            return view
        }()

        private lazy var innerView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.white
            view.layer.cornerRadius = Constant.innerSize.width / 2.0
            return view
        }()

        private struct Constant {
            static let outerSize = CGSize(width: 16.0, height: 16.0)
            static let gapSize = CGSize(width: 14.0, height: 14.0)
            static let innerSize = CGSize(width: 10.0, height: 10.0)
        }

        override init(frame: CGRect) {
            super.init(frame: frame)

            contentView.applyShadow(style: .standard)

            contentView.addSubview(outerView)
            contentView.addSubview(gapView)
            contentView.addSubview(innerView)

            outerView.cerise.layout { builder in
                builder.size == Constant.outerSize
                builder.center == contentView.cerise.centerAnchor
            }

            gapView.cerise.layout { builder in
                builder.size == Constant.gapSize
                builder.center == contentView.cerise.centerAnchor
            }

            innerView.cerise.layout { builder in
                builder.size == Constant.innerSize
                builder.center == contentView.cerise.centerAnchor
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

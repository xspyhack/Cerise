//
//  ObservableConvertibleType+Driver.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 9/13/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import RxCocoa
import RxSwift

// ref: https://github.com/ReactiveX/RxSwift/blob/2.6.0/RxCocoa/Common/CocoaUnits/Driver/ObservableConvertibleType+Driver.swift
extension ObservableConvertibleType where Element == Void {
    func asDriver() -> Driver<Element> {
        return self.asDriver(onErrorJustReturn: Void())
    }
}

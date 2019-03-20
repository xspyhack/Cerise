//
//  ComposerViewModel.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/20.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

struct ComposerViewModel {
    struct Inputs {
        let post = PublishSubject<Void>()
        let cancel = PublishSubject<Void>()
    }

    struct Outputs {
        let dismiss: Driver<Void>
        let isPostEnabled: Driver<Bool>
    }

    let inputs: Inputs
    let outputs: Outputs

    init(matter: Driver<Matter>, validated: Driver<Bool>) {
        inputs = Inputs()

        let didPost = inputs.post.asDriver()
            .withLatestFrom(validated)
            .filter { $0 }
            .withLatestFrom(matter)
            .do(onNext: { matter in
                Matter.didCreate.onNext(matter)
            })
            .map { _ in
            }
            .asDriver()

        let didCancel = inputs.cancel.asDriver()
        let dismiss = Driver.of(didPost, didCancel).merge()

        outputs = Outputs(dismiss: dismiss, isPostEnabled: validated)
    }
}

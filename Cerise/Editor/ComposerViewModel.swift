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
        let draft = PublishSubject<DraftAction>()
    }

    struct Outputs {
        let dismiss: Driver<Void>
        let isPostEnabled: Driver<Bool>
        let attemptToDismiss: Driver<Void>
    }

    enum DraftAction {
        case delete
        case save
    }

    let inputs: Inputs
    let outputs: Outputs
    private let disposeBag = DisposeBag()

    init(matter: Driver<Matter>, validated: Driver<Bool>) {
        inputs = Inputs()

        let didPost = inputs.post.asDriver()
            .withLatestFrom(validated)
            .filter { $0 }
            .withLatestFrom(matter)
            .do(onNext: { matter in
                Matter.didCreate.onNext(matter)
                try? Draft.remove()
            })
            .map { _ in }
            .asDriver()

        let didCancel = inputs.cancel
            .withLatestFrom(validated)
            .filter { !$0 }
            .map { _ in }
            .asDriver()

        let attemptToDismiss = inputs.cancel
            .withLatestFrom(validated)
            .filter { $0 }
            .map { _ in }
            .asDriver()

        let didDraft = inputs.draft
            .withLatestFrom(matter, resultSelector: { ($0, $1) })
            .do(onNext: { action, matter in
                switch action {
                case .delete:
                    try? Draft.remove()
                case .save:
                    try? Draft.store(matter)
                }
            })
            .map { _ in }
            .asDriver()

        let dismiss = Driver.of(didPost, didCancel, didDraft).merge()

        outputs = Outputs(dismiss: dismiss,
                          isPostEnabled: validated,
                          attemptToDismiss: attemptToDismiss)
    }
}

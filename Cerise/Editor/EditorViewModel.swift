//
//  EditorViewModel.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/20.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol EditorViewModelInputs {
}

protocol EditorViewModelOutputs {
    var validated: Driver<Bool> { get }
    var itemsUpdated: PublishSubject<TableViewUpdate> { get }
    var matter: Driver<Matter> { get }
    //var dismiss: Driver<Void> { get }
}

protocol EditorViewModelType {
    var title: BehaviorRelay<String> { get }
    var tag: BehaviorRelay<Tagble> { get }
    var when: BehaviorRelay<Date> { get }
    var notes: BehaviorRelay<String?> { get }
    var inputs: EditorViewModelInputs { get }
    var outputs: EditorViewModelOutputs { get }
}

struct EditorViewModel: EditorViewModelType {
    struct Inputs: EditorViewModelInputs {
    }

    struct Outputs: EditorViewModelOutputs {
        let itemsUpdated = PublishSubject<TableViewUpdate>()
        let validated: Driver<Bool>
        let matter: Driver<Matter>
        //let dismiss: Driver<Void>
    }

    enum Section: Int, CaseIterable {
        case title = 0
        case tag
        case when
        case notes

        var annotation: String {
            switch self {
            case .title:
                return NSLocalizedString("Title", comment: "Editor new matter title")
            case .tag:
                return NSLocalizedString("Tag", comment: "Editor new matter tag")
            case .when:
                return NSLocalizedString("When", comment: "Editor new matter occurrence date")
            case .notes:
                return NSLocalizedString("Notes", comment: "Editor new matter notes")
            }
        }
    }

    let title: BehaviorRelay<String>
    let tag: BehaviorRelay<Tagble>
    let when: BehaviorRelay<Date>
    let notes: BehaviorRelay<String?>

    let inputs: EditorViewModelInputs
    let outputs: EditorViewModelOutputs

    private let disposeBag = DisposeBag()

    init() {
        let draft = try? Draft.retrieve(Matter.self)
        self.title = BehaviorRelay(value: draft?.title ?? "")
        self.tag = BehaviorRelay(value: draft?.tag ?? Tagble.allCases.randomElement() ?? .none)
        self.when = BehaviorRelay(value: draft?.occurrenceDate ?? Date())
        self.notes = BehaviorRelay(value: draft?.notes ?? "")
        let identifier = Driver<String>.just(UUID().uuidString)
        self.inputs = Inputs()

        let validated = self.title.asDriver()
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)
            .startWith(false)

        let matter = Driver.combineLatest(identifier,
                                          title.asDriver(),
                                          tag.asDriver(),
                                          when.asDriver(),
                                          notes.asDriver()
        ) { id, title, tag, occurrenceDate, notes -> Matter in
            return Matter(id: id,
                          title: title,
                          tag: tag,
                          occurrenceDate: occurrenceDate,
                          notes: notes)
        }

        self.outputs = Outputs(validated: validated, matter: matter)

        when.map { _ in IndexPath(row: 0, section: Section.when.rawValue) }
            .map { TableViewUpdate.reloadRows([$0]) }
            .bind(to: outputs.itemsUpdated)
            .disposed(by: disposeBag)
    }
}

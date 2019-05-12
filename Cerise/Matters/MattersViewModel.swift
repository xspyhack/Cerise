//
//  MattersViewModel.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 9/10/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import Keldeo

protocol MattersViewModelInputs {
    var addAction: PublishSubject<Void> { get }
    var itemDeleted: PublishSubject<IndexPath> { get }
    var itemSelected: PublishSubject<IndexPath> { get }
    var refresh: PublishSubject<Void> { get }
}

protocol MattersViewModelOutputs {
    var itemDeselected: PublishSubject<IndexPath> { get }
    var showMatterDetail: PublishSubject<Matter> { get }
    var addNewMatter: PublishSubject<Void> { get }
    var sections: Driver<[MattersViewSection]> { get }
}

protocol MattersViewModelType {
    var inputs: MattersViewModelInputs { get }
    var outputs: MattersViewModelOutputs { get }

    func matter(at indexPath: IndexPath) -> Matter?
}

typealias MattersViewSection = SectionModel<String, MatterCellModelType>

private enum Section: Int {
    case upcoming
    case past

    var title: String {
        switch self {
        case .upcoming:
            return "UPCOMING"
        case .past:
            return "PAST"
        }
    }
}

struct MattersViewModel: MattersViewModelType {
    struct Inputs: MattersViewModelInputs {
        let addAction = PublishSubject<Void>()
        let itemDeleted = PublishSubject<IndexPath>()
        let itemSelected = PublishSubject<IndexPath>()
        let refresh = PublishSubject<Void>()
    }

    struct Outputs: MattersViewModelOutputs {
        let itemDeselected = PublishSubject<IndexPath>()
        let showMatterDetail = PublishSubject<Matter>()
        let addNewMatter = PublishSubject<Void>()
        let sections: Driver<[MattersViewSection]>
    }

    let inputs: MattersViewModelInputs
    let outputs: MattersViewModelOutputs

    private let disposeBag = DisposeBag()
    private(set) var matters: BehaviorRelay<[Matter]>
    private let charmander = Charmander()

    init() {
        let matters = try? charmander.retrieveAll(type: Matter.self)
        self.matters = BehaviorRelay<[Matter]>(value: matters ?? [])

        let sections: Driver<[MattersViewSection]> = self.matters.asObservable()
            .map { matters in
                let comingCellModels = matters.filter { $0.occurrenceDate > Date() }
                    .map(MattersViewController.MatterCellModel.init) as [MatterCellModelType]
                let comingSection = MattersViewSection(model: Section.upcoming.title, items: comingCellModels)

                let pastCellModels = matters.filter { $0.occurrenceDate <= Date() }
                    .map(MattersViewController.MatterCellModel.init) as [MatterCellModelType]
                let pastSection = MattersViewSection(model: Section.past.title, items: pastCellModels)

                return [comingSection, pastSection]
            }
            .asDriver(onErrorJustReturn: [])

        self.inputs = Inputs()
        self.outputs = Outputs(sections: sections)

        binding()
    }

    private func binding() {
        inputs.addAction
            .bind(to: outputs.addNewMatter)
            .disposed(by: disposeBag)

        inputs.itemSelected
            .bind(to: outputs.itemDeselected)
            .disposed(by: disposeBag)

        inputs.itemSelected
            .compactMap { self.matter(at: $0) }
            .bind(to: outputs.showMatterDetail)
            .disposed(by: disposeBag)

        inputs.itemDeleted
            .compactMap { self.matter(at: $0) }
            .bind(to: Matter.didDelete)
            .disposed(by: disposeBag)

        inputs.refresh
            .subscribe(onNext: {
                Log.d("refreshing.")
                let matters = self.matters.value
                self.matters.accept(matters)
            })
            .disposed(by: disposeBag)

        Matter.didCreate
            .do(onNext: { matter in
                try? self.charmander.store(matter, forKey: matter.identifier)
            })
            .subscribe(onNext: { matter in
                var matters = self.matters.value
                matters.insert(matter, at: 0)
                self.matters.accept(matters)
            })
            .disposed(by: disposeBag)

        Matter.didDelete
            .do(onNext: { matter in
                try? self.charmander.remove(forKey: matter.identifier)
            })
            .subscribe(onNext: { matter in
                guard let index = self.matters.value.firstIndex(of: matter) else {
                    return
                }
                var matters = self.matters.value
                matters.remove(at: index)
                self.matters.accept(matters)
            })
            .disposed(by: disposeBag)

        Matter.didUpdate
            .do(onNext: { matter in
                try? self.charmander.remove(forKey: matter.identifier)
                try? self.charmander.store(matter, forKey: matter.identifier)
            })
            .subscribe(onNext: { matter in
                guard let index = self.matters.value.firstIndex(of: matter) else {
                    return
                }
                var matters = self.matters.value
                matters[index] = matter
                self.matters.accept(matters)
            })
            .disposed(by: disposeBag)
    }
}

extension MattersViewModel {
    func matter(at indexPath: IndexPath) -> Matter? {
        guard let section = Section(rawValue: indexPath.section) else {
            return nil
        }
        switch section {
        case .upcoming:
            let comings = matters.value.filter { $0.occurrenceDate > Date() }
            return comings.safe[indexPath.row]
        case .past:
            let pasts = matters.value.filter { $0.occurrenceDate <= Date() }
            return pasts.safe[indexPath.row]
        }
    }

    func index(of matter: Matter) -> Int? {
        return matters.value.firstIndex(of: matter)
    }
}

extension Matter: StoreKey {
    var identifier: String {
        return id.replacingOccurrences(of: "-", with: "").lowercased()
    }
}

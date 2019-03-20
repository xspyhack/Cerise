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

protocol MattersViewModelInputs {
    var addAction: PublishSubject<Void> { get }
    var itemDeleted: PublishSubject<IndexPath> { get }
    var itemSelected: PublishSubject<IndexPath> { get }
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

    init() {
        let matters = BehaviorRelay<[Matter]>(value: Matter.mock())
        self.matters = matters

        let sections: Driver<[MattersViewSection]> = matters.asObservable()
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
            .map { self.matter(at: $0) }
            .filter { $0 != nil }
            .map { $0! }
            .bind(to: outputs.showMatterDetail)
            .disposed(by: disposeBag)

        Matter.didCreate
            .subscribe(onNext: { matter in
                var matters = self.matters.value
                matters.insert(matter, at: 0)
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
}

//    init(with userID: String? = nil) {
//      
//        func update(_ matters: [Matter]) {
//            let mattersDictionary = (matters.map { Matter.shared(with: $0) }).map { $0.json }
//            do {
//                try WatchSessionService.shared.update(withApplicationContext: [Configuration.sharedMattersKey: mattersDictionary])
//            } catch {
//                if !WatchSessionService.shared.isInstalled {
//                    Defaults.watchState.value = WatchState.notInstalled.rawValue
//                } else if !WatchSessionService.shared.isPaired {
//                    Defaults.watchState.value = WatchState.unpaired.rawValue
//                }
//                print("Error updating watch application context: \(error.localizedDescription)")
//            }
//        }
//        
//        let predicate: NSPredicate
//        if let userID = userID {
//            predicate = NSPredicate(format: "creator.id = %@", userID)
//        } else {
//            predicate = NSPredicate(value: true)
//        }
//        
//        let matters = Variable<[Matter]>(MatterService.shared.fetchAll(withPredicate: predicate,fromRealm: realm).sorted(by: { (matter0, matter1) in
//            matter0.happenedAt > matter1.happenedAt
//        }))
//       
//        // Sync to watchOS
//        
//        delay(1.0) {
//            update(matters.value)
//        }
//        
//        self.matters = matters
//        
//        // 这样写，无法根据 section 来 delete 对应 matter，如果不怕牺牲性能，可以在删除的时候重新分组
//        self.sections = matters.asObservable()
//            .map { matters in
//                let commingCellModels = matters.filter { $0.happenedAt > Date().timeIntervalSince1970 }.map(MatterCellModel.init) as [MatterCellModelType]
//                let commingSection = MattersViewSection(model: Section.comming.title, items: commingCellModels)
//                
//                let pastCellModels = matters.filter { $0.happenedAt <= Date().timeIntervalSince1970 }.map(MatterCellModel.init) as [MatterCellModelType]
//                let pastSection = MattersViewSection(model: Section.past.title, items: pastCellModels)
//                return [commingSection, pastSection]
//            }
//            .asDriver(onErrorJustReturn: [])
//
//        self.itemDeleted
//            .subscribe(onNext: { indexPath in
//                // 先分组
//                guard let section = Section(rawValue: indexPath.section) else { return }
//                
//                if section == .comming {
//                    let commings = matters.value.filter { $0.happenedAt > Date().timeIntervalSince1970 }
//                    
//                    if let matter = commings.safe[indexPath.row] {
//                        Matter.didDelete.onNext(matter)
//                    }
//                } else {
//                    let pasts = matters.value.filter{ $0.happenedAt <= Date().timeIntervalSince1970 }
//                    
//                    if let matter = pasts.safe[indexPath.row] {
//                        Matter.didDelete.onNext(matter)
//                    }
//                }
//            })
//            .disposed(by: disposeBag)
//        
//        self.showMatterViewModel = self.itemDidSelect
//            .map { indexPath in
//                // 先分组
//                if indexPath.section == Section.comming.rawValue {
//                    let commings = matters.value.filter { $0.happenedAt > Date().timeIntervalSince1970 }
//                    
//                    if let matter = commings.safe[indexPath.row] {
//                        return MatterViewModel(matter: matter)
//                    }
//                } else {
//                    let pasts = matters.value.filter{ $0.happenedAt <= Date().timeIntervalSince1970 }
//                    
//                    if let matter = pasts.safe[indexPath.row] {
//                        return MatterViewModel(matter: matter)
//                    }
//                }
//                return MatterViewModel(matter: Matter())
//            }
//            .asDriver(onErrorDriveWith: .never())
//        
//        self.itemDidDeselect = self.itemDidSelect.asDriver(onErrorJustReturn: IndexPath())
//        
//        self.showNewMatterViewModel = self.addAction.asDriver()
//            .map {
//                NewMatterViewModel()
//            }
//        
//        // Services
//  
//        Matter.didCreate
//            .subscribe(onNext: { matter in
//                matters.value.insert(matter, at: 0)
//                MatterService.shared.synchronize(matter, toRealm: realm)
//                
//                update(matters.value)
//            })
//            .disposed(by: disposeBag)
//        
//        Matter.didDelete
//            .subscribe(onNext: { matter in
//                if let index = matters.value.index(of: matter) {
//                    matters.value.remove(at: index)
//                    MatterService.shared.remove(matter, fromRealm: realm)
//                    
//                    update(matters.value)
//                }
//            })
//            .disposed(by: disposeBag)
//    }
//    
//}
//
//extension Matter: ModelType {}

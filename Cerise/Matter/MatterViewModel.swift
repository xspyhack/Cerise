//
//  MatterViewModel.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 8/15/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

protocol MatterViewModelType {
    var matter: Matter { get }
    var title: Driver<String?> { get }
    var when: Driver<String?> { get }
    var notes: Driver<String?> { get }
}

struct MatterViewModel: MatterViewModelType {
    var title: Driver<String?>
    //var tag: Driver<UIColor?>
    var when: Driver<String?>
    var notes: Driver<String?>

    let matter: Matter
    private let disposeBag = DisposeBag()

    init(matter: Matter) {
        self.matter = matter
        self.title = Driver.just(matter.title)
        //self.tag = Driver.just(UIColor(hex: Tag(rawValue: matter.tag)?.value ?? Tag.none.value))
        self.when = Driver.just(matter.occurrenceDate.cerise.yearMonthDay)
        self.notes = Driver.just(matter.notes)
    }
}

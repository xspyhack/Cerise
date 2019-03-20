//
//  ModelService.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation
import RxSwift

private class Store {
    static let shared = Store()
    var instances = [String: Any]()
}

protocol ModelType {}

struct ModelService<Model: ModelType> {
    let didCreate = PublishSubject<Model>()
    let didUpdate = PublishSubject<Model>()
    let didDelete = PublishSubject<Model>()

    static func instance(_ modelClass: Model.Type) -> ModelService<Model> {
        let key = String(describing: modelClass)
        if let stream = Store.shared.instances[key] as? ModelService<Model> {
            return stream
        }
        let stream = ModelService<Model>()
        Store.shared.instances[key] = stream
        return stream
    }

}

extension ModelType {
    static var didCreate: PublishSubject<Self> {
        return ModelService.instance(Self.self).didCreate
    }

    static var didUpdate: PublishSubject<Self> {
        return ModelService.instance(Self.self).didUpdate
    }

    static var didDelete: PublishSubject<Self> {
        return ModelService.instance(Self.self).didDelete
    }
}

extension Matter: ModelType {}

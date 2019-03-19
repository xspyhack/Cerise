//
//  AppEnvironment.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation

struct AppEnvironment {
    static let environmentStorageKey = "com.cerise.AppEnvironment.current"

    static var stack: [Environment] = [Environment()]

    /// 更新环境类型
    static func update(environmentType: Environment.EnvironmentType) {
        replace(type: environmentType)
    }

    // swiftlint:disable implicitly_unwrapped_optional
    static var current: Environment! {
        return stack.last
    }
    // swiftlint:enable implicitly_unwrapped_optional

    static func push(_ environment: Environment) {
        save(environment, into: environment.userDefaults)
        stack.append(environment)
    }

    static func pop() -> Environment? {
        let last = stack.popLast()
        let next = current ?? Environment()
        save(next, into: next.userDefaults)
        return last
    }

    static func replace(_ environment: Environment) {
        push(environment)
        stack.remove(at: stack.count - 2)
    }

    static func replace(type: Environment.EnvironmentType = AppEnvironment.current.type) {
        let environment = Environment(type: type,
                                      userDefaults: AppEnvironment.current.userDefaults)
        replace(environment)
    }

    static func fromStorage(userDefaults: UserDefaults) -> Environment {
        let data = userDefaults.dictionary(forKey: environmentStorageKey) ?? [:]

         var environmentType: Environment.EnvironmentType = .release
         if let typeString = data["type"] as? String, let type = Environment.EnvironmentType(rawValue: typeString) {
            environmentType = type
         }

        return Environment(type: environmentType)
    }

    static func save(_ environment: Environment, into userDefaults: UserDefaults) {
        var data: [String: Any] = [:]
        data["type"] = environment.type.rawValue
        userDefaults.set(data, forKey: environmentStorageKey)
    }
}

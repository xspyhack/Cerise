//
//  UIStoryboard+Cerise.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

extension UIStoryboard {
    enum Storyboard: String {
        case main
        case matters
        case matter

        var value: String {
            return self.rawValue.capitalized
        }
    }
}

extension Cerise where Base: UIStoryboard {
    static func storyboard(_ board: UIStoryboard.Storyboard) -> UIStoryboard {
        return UIStoryboard(name: board.value, bundle: nil)
    }
}

enum Storyboard: String {
    case main

    case matters
    case matter

    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue.cerise.uppercased(1), bundle: nil)
    }

    func viewController<T: UIViewController>(of viewControllerType: T.Type) -> T {
        return instance.instantiateViewController(withIdentifier: "\(T.self)") as! T
    }

    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }

    func navigationController(with identifier: String) -> UIViewController {
        return instance.instantiateViewController(withIdentifier: identifier)
    }
}

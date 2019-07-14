//
//  Router.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation
import Ditto
import Keldeo
import SafariServices

struct RoutingCoordinator {
    enum Representaion {
        case push(from: UINavigationController, animated: Bool)
        case present(from: UIViewController, animated: Bool)

        var animated: Bool {
            switch self {
            case .push(_, animated: let animated):
                return animated
            case .present(_, animated: let animated):
                return animated
            }
        }

        var viewController: UIViewController {
            switch self {
            case .push(from: let viewController, _):
                return viewController
            case .present(from: let viewController, _):
                return viewController
            }
        }
    }

    let isFromLaunching: Bool
    let representation: Representaion

    /// 如果是 from launching，则忽略 coordinator 里面的 animated
    var animated: Bool {
        return isFromLaunching ? false : representation.animated
    }

    /// 用来 present 的 view controller
    var viewController: UIViewController {
        return representation.viewController
    }

    /// present 一个 view controller
    func present(_ vc: UIViewController) {
        viewController.present(vc, animated: animated, completion: nil)
    }

    /// 根据当前的场景来 push 一个 view controller
    func pushViewController(_ vc: UIViewController) {
        (viewController as? UINavigationController)?.pushViewController(vc, animated: animated)
    }

    /// 根据 representaion 决定是 push 还是 present
    func show(_ vc: UIViewController) {
        switch representation {
        case .push(let navigationController, _):
            navigationController.pushViewController(vc, animated: animated)
        case .present(let viewController, _):
            viewController.present(vc, animated: animated, completion: nil)
        }
    }
}

protocol RoutingCoordinatorDelegate: class {
    func coordinatorRepresentation() -> RoutingCoordinator.Representaion
}

class Router {
    static let shared = Router()
    private let router: Ditto.Router<RoutingCoordinator>

    weak var delegate: RoutingCoordinatorDelegate?

    private init() {
        router = Ditto.Router(schemes: ["cerise"])
    }

    static func register() {
        try? shared.router.register([
            // 强制用浏览器打开链接
            // cerise://browser?link=[url]
            ("development://browser", { context in
                guard let url: URL = context.parameter(forKey: "link") else {
                    return false
                }
                // always present
                let safariViewController = SFSafariViewController(url: url)
                let coordinator = context.coordinator
                coordinator.present(safariViewController)
                return true
            }),
            // 反馈
            ("cerise://feedback", { context in
                FeedbackContoller.shared.feedback(in: context.coordinator.representation.viewController) {
                    context.coordinator.representation.viewController.dismiss(animated: true, completion: nil)
                }
                return true
            }),
            // 清楚本地数据
            ("cerise://development/clean", { context in
                let disk = Disk()
                do {
                    try disk.clear(.caches)
                } catch {
                    Log.e("Clean caches failed: \(error)")
                }
                return true
            }),
            // 切换网络环境
            // cerise://development/environment?type=[debug|release]
            ("cerise://development/environment", { context in
                guard let type: Environment.EnvironmentType = context.parameter(forKey: "type") else {
                    return false
                }

                AppEnvironment.update(environmentType: type)
                return true
            }),
        ])
    }

    @discardableResult
    static func route(to destination: Routable, coordinator: RoutingCoordinator) -> Bool {
        return shared.router.route(to: destination, coordinator: coordinator)
    }

    static func responds(to destination: Routable, coordinator: RoutingCoordinator) -> Bool {
        return shared.router.responds(to: destination, coordinator: coordinator)
    }

    @discardableResult
    static func route(to destination: Routable, isFromLaunching: Bool = false) -> Bool {
        guard let representation = shared.delegate?.coordinatorRepresentation() else {
            return false
        }
        let coordinator = RoutingCoordinator(isFromLaunching: isFromLaunching, representation: representation)
        return shared.router.route(to: destination, coordinator: coordinator)
    }

    static func responds(to destination: Routable) -> Bool {
        guard let representation = shared.delegate?.coordinatorRepresentation() else {
            return false
        }
        let coordinator = RoutingCoordinator(isFromLaunching: false, representation: representation)
        return shared.router.responds(to: destination, coordinator: coordinator)
    }
}

extension Router {
    enum Endpoint: Routable {
        case home
        case matter(String)
        case feedback
        case browser(URL)

        var url: URL {
            switch self {
            case .home:
                return URL(string: "cerise://home")!
            case .matter(let id):
                return URL(string: "cerise://matters/\(id)")!
            case .feedback:
                return URL(string: "cerise://feedback")!
            case .browser(let link):
                return URL(string: "cerise://browser?link=\(link)")!
            }
        }
    }

    @discardableResult
    static func route(to endpoint: Endpoint, isFromLaunching: Bool = false) -> Bool {
        guard let representation = shared.delegate?.coordinatorRepresentation() else {
            return false
        }
        let coordinator = RoutingCoordinator(isFromLaunching: isFromLaunching, representation: representation)
        return shared.router.route(to: endpoint, coordinator: coordinator)
    }

    static func responds(to endpoint: Endpoint) -> Bool {
        guard let representation = shared.delegate?.coordinatorRepresentation() else {
            return false
        }
        let coordinator = RoutingCoordinator(isFromLaunching: false, representation: representation)
        return shared.router.responds(to: endpoint, coordinator: coordinator)
    }
}

extension Environment.EnvironmentType: Extractable {
    public static func extract(from string: String) -> Environment.EnvironmentType? {
        return Environment.EnvironmentType(rawValue: string)
    }
}

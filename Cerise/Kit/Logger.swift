//
//  Logger.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/19.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation
import Keldeo

enum Logger {
    static func setUp() {
        let formatter = LogFormatter()

        if Environment.type == .debug {
            let consoleLogger = Loggers.Console(level: .debug, formatter: formatter)
            Keldeo.Logger.shared.add(AnyLogger(consoleLogger))
        } else {
            let fileManager = FileManagers.Default()
            if let fileLogger = Loggers.File(level: .info, formatter: formatter, fileManager: fileManager) {
                Keldeo.Logger.shared.add(AnyLogger(fileLogger))
                print("Log directory: \(fileManager.directory)")
            }
        }
    }
}

struct LogFormatter: Keldeo.Formatter {
    let dateFormatter: DateFormatter

    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSS"
    }

    func format(message: Keldeo.Message) -> String {
        var string = ""
        let level: String

        switch message.level {
        case .error:
            level = "❌"
        case .warning:
            level = "⚠️"
        case .info:
            level = "🐊"
        case .debug:
            level = "💊"
        case .off:
            level = ""
        }
        string += "\(level) "

        let timestamp = dateFormatter.string(from: message.timestamp)
        string += "\(timestamp) "

        let file = (message.file as NSString).lastPathComponent
        string += "[\(file):\(message.line)] \(message.function) "

        string += "| \(message.message)"

        return string
    }
}

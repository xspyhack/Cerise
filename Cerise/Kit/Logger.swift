//
//  Logger.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/19.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation
import Keldeo

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

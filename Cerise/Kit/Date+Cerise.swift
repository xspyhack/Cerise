//
//  Date+Cerise.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/19.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation

extension Date: CeriseCompatible {
}

public extension Cerise where Base == Date {
    public var timestamp: String {
        _Date.formatter.dateFormat = Date.timestampFormatString
        return _Date.formatter.string(from: base)
    }

    public var dmyAtHourMinute: String {
        _Date.formatter.dateFormat = "dd MMM, yyyy 'at' HH:mm"
        return _Date.formatter.string(from: base)
    }

    public var monthDayYear: String {
        _Date.formatter.dateFormat = Date.mdyDateFormatString
        return _Date.formatter.string(from: base)
    }

    public var yearMonthDay: String {
        _Date.formatter.dateFormat = "yyyy/MM/dd"
        return _Date.formatter.string(from: base)
    }

    public var monthDay: String {
        _Date.formatter.dateFormat = "MM/dd"
        return _Date.formatter.string(from: base)
    }

    public var year: String {
        _Date.formatter.dateFormat = "yyyy"
        return _Date.formatter.string(from: base)
    }

    public var month: String {
        _Date.formatter.dateFormat = "MM"
        return _Date.formatter.string(from: base)
    }

    public var day: String {
        _Date.formatter.dateFormat = "dd"
        return _Date.formatter.string(from: base)
    }

    public var hour: String {
        _Date.formatter.dateFormat = "HH"
        return _Date.formatter.string(from: base)
    }

    public var minute: String {
        _Date.formatter.dateFormat = "mm"
        return _Date.formatter.string(from: base)
    }

    public var time: String {
        _Date.formatter.dateFormat = "HH:mm"
        return _Date.formatter.string(from: base)
    }

    public func days(with comparingDate: Date) -> Int {
        return Cerise.daysOffset(between: base, and: comparingDate)
    }

    public func absoluteDays(with comparingDate: Date) -> Int {
        return Cerise.absoluteDaysOffset(between: base, and: comparingDate)
    }

    public static func daysOffset(between startDate: Date, and endDate: Date) -> Int {
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)

        let comps = gregorian.dateComponents([.day], from: startDate, to: endDate)
        return (comps.day ?? 0)
    }

    public static func absoluteDaysOffset(between startDate: Date, and endDate: Date) -> Int {
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)

        let fromDate = gregorian.date(bySettingHour: 12, minute: 0, second: 0, of: startDate) ?? startDate
        let toDate = gregorian.date(bySettingHour: 12, minute: 0, second: 0, of: endDate) ?? endDate

        let comps = gregorian.dateComponents([.day], from: fromDate, to: toDate)
        return (comps.day ?? 0)
    }

    public static func date(with aString: String, format: String = Date.timestampFormatString) -> Date? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = format

        return inputFormatter.date(from: aString)
    }

    /// `0`: Sunday and `6`: Saturday
    /// -returns 0...6
    public var weekdayIndex: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.calendar, .weekday, .weekdayOrdinal], from: base)
        return (components.weekday ?? 0) - 1
    }
}

private struct _Date {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US") // No localized string
        return formatter
    }()
}

public extension Date {
    static let dateFormatString = "yyyy-MM-dd"
    static let mdyDateFormatString = "MMM dd, yyy"
    static let timeFormatString = "HH:mm:ss"
    static let timestampFormatString = "yyyy-MM-dd'T'HH:mm:ssZ"
}

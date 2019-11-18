//
//  extension Date
//  RsyncOSX
//
//  Created by Thomas Evensen on 08/12/2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

extension Date {

    func weekday(date: Date) -> Int {
        let calendar = Calendar.current
        let dateComponent = (calendar as NSCalendar).components(.weekday, from: self)
        return dateComponent.weekday!
    }

    func numberOfDaysInMonth() -> Int {
        let calendar = Calendar.current
        let days = (calendar as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: self)
        return days.length
    }

    func dateByAddingMonths(_ months: Int ) -> Date {
        let calendar = Calendar.current
        var dateComponent = DateComponents()
        dateComponent.month = months
        return (calendar as NSCalendar).date(byAdding: dateComponent, to: self, options: NSCalendar.Options.matchNextTime)!
    }

    func dateByAddingDays(_ days: Int ) -> Date {
        let calendar = Calendar.current
        var dateComponent = DateComponents()
        dateComponent.day = days
        return (calendar as NSCalendar).date(byAdding: dateComponent, to: self, options: NSCalendar.Options.matchNextTime)!
    }

    func daymonth() -> Int {
        let calendar = Calendar.current
        let dateComponent = (calendar as NSCalendar).components(.day, from: self)
        return dateComponent.day!
    }

    func isSaturday() -> Bool {
        return (self.getWeekday() == 7)
    }

    func isSunday() -> Bool {
        return getWeekday() == 1
    }

    func isWeekday() -> Bool {
        return getWeekday() != 1
    }

    func getWeekday() -> Int {
        let calendar = Calendar.current
        return (calendar as NSCalendar).components( .weekday, from: self).weekday!
    }

    func isSelectedDayofWeek(day: NumDayofweek) -> Bool {
        return getWeekday() == day.rawValue
    }

    func monthNameFull() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM YYYY"
        return dateFormatter.string(from: self)
    }

    func monthNameShort() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: self)
    }

    func dayNameShort() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }

    func month() -> Int {
        let calendar = Calendar.current
        let dateComponent = (calendar as NSCalendar).components(.month, from: self)
        return dateComponent.month!
    }

    func year() -> Int {
        let calendar = Calendar.current
        let dateComponent = (calendar as NSCalendar).components(.year, from: self)
        return dateComponent.year!
    }

    func localizeDate() -> String {
        let formatter = DateFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    static func == (lhs: Date, rhs: Date) -> Bool {
        return lhs.compare(rhs) == ComparisonResult.orderedSame
    }

    static func < (lhs: Date, rhs: Date) -> Bool {
        return lhs.compare(rhs) == ComparisonResult.orderedAscending
    }

    static func > (lhs: Date, rhs: Date) -> Bool {
        return rhs.compare(lhs) == ComparisonResult.orderedAscending
    }

    func ispreviosmonth() -> Bool {
        let calendar = Calendar.current
        let yearComponent = (calendar as NSCalendar).components(.year, from: self)
        let monthComponent = (calendar as NSCalendar).components(.month, from: self)
        let today = Date()
        let todayComponentyear = (calendar as NSCalendar).components(.year, from: today)
        let todaymonthComponent = (calendar as NSCalendar).components(.month, from: today)
        if yearComponent == todayComponentyear {
            if monthComponent.month! == todaymonthComponent.month! - 1 {
                return true
            }
        }
        return false
    }

    func isearliermonth() -> Bool {
        let calendar = Calendar.current
        let yearComponent = (calendar as NSCalendar).components(.year, from: self)
        let monthComponent = (calendar as NSCalendar).components(.month, from: self)
        let today = Date()
        let todayComponentyear = (calendar as NSCalendar).components(.year, from: today)
        let todaymonthComponent = (calendar as NSCalendar).components(.month, from: today)
        if yearComponent.year! <= todayComponentyear.year! {
            if monthComponent.month! < todaymonthComponent.month! - 1 {
                return true
            }
        }
        return false
    }

    // Returns a DateComponent value with number of days away from a specified date
    var dayssincenow: DateComponents {
        let now = Date()
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "en_US")
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .short
        dateformatter.dateFormat = "dd MMM yyyy HH:mm"
        return Calendar.current.dateComponents([.day], from: self, to: now)
    }

    var weekssincenowplusoneweek: DateComponents {
        let now = Date()
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "en_US")
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .short
        dateformatter.dateFormat = "dd MMM yyyy HH:mm"
        return Calendar.current.dateComponents([.weekOfYear], from: self, to: now.dateByAddingDays(7))
    }

    var localized_string_from_date: String {
        let dateformatter = DateFormatter()
        dateformatter.formatterBehavior = .behavior10_4
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .short
        return dateformatter.string(from: self)
    }

    init(year: Int, month: Int, day: Int) {
        let calendar = Calendar.current
        var dateComponent = DateComponents()
        dateComponent.year = year
        dateComponent.month = month
        dateComponent.day = day
        self = calendar.date(from: dateComponent)!
    }
}

extension String {

    var en_us_date_from_string: Date {
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "en_US")
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .short
        dateformatter.dateFormat = "dd MMM yyyy HH:mm"
        return dateformatter.date(from: self) ?? Date()
    }

    var localized_date_from_string: Date {
        let dateformatter = DateFormatter()
        dateformatter.formatterBehavior = .behavior10_4
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .short
        return dateformatter.date(from: self) ?? Date()
    }
}

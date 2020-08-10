//
//  Tagsnapshots.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

enum NumDayofweek: Int {
    case Monday = 2
    case Tuesday = 3
    case Wednesday = 4
    case Thursday = 5
    case Friday = 6
    case Saturday = 7
    case Sunday = 1
}

enum StringDayofweek: String {
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
}

class Tagsnapshots {
    var day: NumDayofweek?
    var nameofday: StringDayofweek?
    var daylocalized = [NSLocalizedString("Sunday", comment: "plan"),
                        NSLocalizedString("Monday", comment: "plan"),
                        NSLocalizedString("Tuesday", comment: "plan"),
                        NSLocalizedString("Wednesday", comment: "plan"),
                        NSLocalizedString("Thursday", comment: "plan"),
                        NSLocalizedString("Friday", comment: "plan"),
                        NSLocalizedString("Saturday", comment: "plan")]
    weak var reloadDelegate: Reloadandrefresh?
    var snapshotlogsandcatalogs: Snapshotlogsandcatalogs?
    private var numberoflogs: Int?
    private var keepallselcteddayofweek: Bool = true
    var now: String?

    func islastSundayinMonth(date: Date) -> Bool {
        if date.isSunday(), date.daymonth() > 24 {
            return true
        } else {
            return false
        }
    }

    func isaSunday(date: Date) -> Bool {
        return date.isSunday()
    }

    private func datefromstring(datestringlocalized: String) -> Date {
        guard datestringlocalized != "no log" else { return Date() }
        return datestringlocalized.localized_date_from_string()
    }

    private func datecomponentsfromstring(datestringlocalized: String?) -> DateComponents {
        var date: Date?
        if datestringlocalized != nil {
            date = self.datefromstring(datestringlocalized: datestringlocalized!)
        }
        let calendar = Calendar.current
        return calendar.dateComponents([.calendar, .timeZone,
                                        .year, .month, .day,
                                        .hour, .minute,
                                        .weekday, .weekOfYear, .year], from: date ?? Date())
    }

    private func markfordelete() {
        guard self.snapshotlogsandcatalogs?.snapshotslogs != nil else { return }
        for i in 0 ..< (self.snapshotlogsandcatalogs?.snapshotslogs?.count ?? 0) {
            let index = (self.snapshotlogsandcatalogs?.snapshotslogs?.count ?? 0) - 1 - i
            if self.currentweek(index: index) {
                self.snapshotlogsandcatalogs?.snapshotslogs![index].setValue(0, forKey: "selectCellID")
            } else if self.currentdaymonth(index: index) {
                self.snapshotlogsandcatalogs?.snapshotslogs![index].setValue(1, forKey: "selectCellID")
            } else {
                if self.keepallorlastdayinperiod(index: index) {
                    self.snapshotlogsandcatalogs?.snapshotslogs![index].setValue(1, forKey: "selectCellID")
                }
            }
        }
        self.reloadDelegate?.reloadtabledata()
    }

    // Keep all snapshots current week.
    private func currentweek(index: Int) -> Bool {
        let datesnapshotstring = (self.snapshotlogsandcatalogs?.snapshotslogs![index].value(forKey: "dateExecuted") as? String)!
        if self.datecomponentsfromstring(datestringlocalized: datesnapshotstring).weekOfYear ==
            self.datecomponentsfromstring(datestringlocalized: self.now).weekOfYear,
            self.datecomponentsfromstring(datestringlocalized: datesnapshotstring).year ==
            self.datecomponentsfromstring(datestringlocalized: self.now).year
        {
            let tag = NSLocalizedString("Keep", comment: "plan") + " " + NSLocalizedString("this week", comment: "plan")
            self.snapshotlogsandcatalogs?.snapshotslogs?[index].setValue(tag, forKey: "period")
            return true
        }
        return false
    }

    // Keep snapshots every choosen day this month ex current week
    private func currentdaymonth(index: Int) -> Bool {
        let datesnapshotstring = (self.snapshotlogsandcatalogs?.snapshotslogs![index].value(forKey: "dateExecuted") as? String)!
        let month = self.datefromstring(datestringlocalized: datesnapshotstring).monthNameShort()
        let day = self.datefromstring(datestringlocalized: datesnapshotstring).dayNameShort()
        if self.datecomponentsfromstring(datestringlocalized: datesnapshotstring).month ==
            self.datecomponentsfromstring(datestringlocalized: self.now).month,
            self.datecomponentsfromstring(datestringlocalized: datesnapshotstring).year == self.datecomponentsfromstring(datestringlocalized: self.now).year
        {
            if self.datefromstring(datestringlocalized: datesnapshotstring).isSelectedDayofWeek(day: self.day!) == false {
                let tag = NSLocalizedString("Delete", comment: "plan") + " " + day + ", " + month + " " + NSLocalizedString("this month", comment: "plan")
                self.snapshotlogsandcatalogs?.snapshotslogs?[index].setValue(tag, forKey: "period")
                return true
            } else {
                let tag = NSLocalizedString("Keep", comment: "plan") + " " + month + " " + self.daylocalized[self.day!.rawValue - 1] + " " + NSLocalizedString("this month", comment: "plan")
                self.snapshotlogsandcatalogs?.snapshotslogs?[index].setValue(tag, forKey: "period")
                return false
            }
        }
        return false
    }

    typealias Keepallorlastdayinperiodfunc = (Date) -> Bool

    func keepallorlastdayinperiod(index: Int) -> Bool {
        var check: Keepallorlastdayinperiodfunc?
        if self.keepallselcteddayofweek {
            check = self.isselectedDayinWeek
        } else {
            check = self.islastSelectedDayinMonth
        }
        let datesnapshotstring = (self.snapshotlogsandcatalogs!.snapshotslogs![index].value(forKey: "dateExecuted") as? String)!
        let month = self.datefromstring(datestringlocalized: datesnapshotstring).monthNameShort()
        let day = self.datefromstring(datestringlocalized: datesnapshotstring).dayNameShort()
        if self.datecomponentsfromstring(datestringlocalized: datesnapshotstring).month !=
            self.datecomponentsfromstring(datestringlocalized: self.now).month ||
            self.datecomponentsfromstring(datestringlocalized: datesnapshotstring).year! <
            self.datecomponentsfromstring(datestringlocalized: self.now).year!
        {
            if check!(self.datefromstring(datestringlocalized: datesnapshotstring)) == true {
                if self.datecomponentsfromstring(datestringlocalized: datesnapshotstring).month == self.datecomponentsfromstring(datestringlocalized: self.now).month! - 1 {
                    let tag = NSLocalizedString("Keep", comment: "plan") + " " + day + ", " + month + " " + NSLocalizedString("previous month", comment: "plan")
                    self.snapshotlogsandcatalogs?.snapshotslogs![index].setValue(tag, forKey: "period")
                } else {
                    let tag = NSLocalizedString("Keep", comment: "plan") + " " + day + ", " + month + " " + NSLocalizedString("earlier months", comment: "plan")
                    self.snapshotlogsandcatalogs?.snapshotslogs![index].setValue(tag, forKey: "period")
                }
                return false
            } else {
                let date = self.datefromstring(datestringlocalized: datesnapshotstring)
                if date.ispreviousmont {
                    let tag = NSLocalizedString("Delete", comment: "plan") + " " + day + ", " + month + " " + NSLocalizedString("previous month", comment: "plan")
                    self.snapshotlogsandcatalogs?.snapshotslogs![index].setValue(tag, forKey: "period")
                } else {
                    let tag = NSLocalizedString("Delete", comment: "plan") + " " + day + ", " + month + " " + NSLocalizedString("earlier months", comment: "plan")
                    self.snapshotlogsandcatalogs?.snapshotslogs![index].setValue(tag, forKey: "period")
                }
                return true
            }
        }
        return false
    }

    func islastSelectedDayinMonth(_ date: Date) -> Bool {
        if date.isSelectedDayofWeek(day: self.day!), date.daymonth() > 24 {
            return true
        } else {
            return false
        }
    }

    func isselectedDayinWeek(_ date: Date) -> Bool {
        return self.day!.rawValue == date.getWeekday()
    }

    private func reset() {
        for i in 0 ..< (self.snapshotlogsandcatalogs?.snapshotslogs?.count ?? 0) {
            self.snapshotlogsandcatalogs?.snapshotslogs?[i].setValue(0, forKey: "selectCellID")
        }
    }

    private func setweekdaytokeep(snapdayoffweek: String) {
        switch snapdayoffweek {
        case StringDayofweek.Monday.rawValue:
            self.day = .Monday
            self.nameofday = .Monday
        case StringDayofweek.Tuesday.rawValue:
            self.day = .Tuesday
            self.nameofday = .Tuesday
        case StringDayofweek.Wednesday.rawValue:
            self.day = .Wednesday
            self.nameofday = .Wednesday
        case StringDayofweek.Thursday.rawValue:
            self.day = .Thursday
            self.nameofday = .Thursday
        case StringDayofweek.Friday.rawValue:
            self.day = .Friday
            self.nameofday = .Friday
        case StringDayofweek.Saturday.rawValue:
            self.day = .Saturday
            self.nameofday = .Saturday
        case StringDayofweek.Sunday.rawValue:
            self.day = .Sunday
            self.nameofday = .Sunday
        default:
            self.day = .Sunday
            self.nameofday = .Sunday
        }
    }

    init(plan: Int, snapdayoffweek: String, snapshotsloggdata: Snapshotlogsandcatalogs?) {
        // which plan to apply
        if plan == 1 {
            self.keepallselcteddayofweek = true
        } else {
            self.keepallselcteddayofweek = false
        }
        self.setweekdaytokeep(snapdayoffweek: snapdayoffweek)
        self.reloadDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        self.snapshotlogsandcatalogs = snapshotsloggdata
        guard snapshotsloggdata?.snapshotslogs != nil else { return }
        self.numberoflogs = snapshotsloggdata?.snapshotslogs?.count ?? 0
        self.now = Date().localized_string_from_date()
        self.reset()
        self.markfordelete()
    }
}

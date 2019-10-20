//
//  PlanSnapshots.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

protocol GetSnapshotsLoggData: class {
    func getsnapshotsloggdata() -> SnapshotsLoggData?
}

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

class PlanSnapshots {

    var day: NumDayofweek?
    var nameofday: StringDayofweek?
    var daylocalized = [NSLocalizedString("Sunday", comment: "plan"),
                        NSLocalizedString("Monday", comment: "plan"),
                        NSLocalizedString("Tuesday", comment: "plan"),
                        NSLocalizedString("Wednesday", comment: "plan"),
                        NSLocalizedString("Thursday", comment: "plan"),
                        NSLocalizedString("Friday", comment: "plan"),
                        NSLocalizedString("Saturday", comment: "plan")]
    weak var SnapshotsLoggDataDelegate: GetSnapshotsLoggData?
    weak var reloadDelegate: Reloadandrefresh?
    var snapshotsloggdata: SnapshotsLoggData?
    private var numberoflogs: Int?
    private var firstlog: Double?
    private var keepallselcteddayofweek: Bool = true
    var now: String?

    func islastSundayinMonth(date: Date) -> Bool {
        if date.isSunday() && date.daymonth() > 24 {
            return true
        } else {
            return false
        }
    }

    func isaSunday(date: Date) -> Bool {
        return date.isSunday()
    }

    private func datefromstring(datestringlocalized: String) -> Date {
        let formatter = DateFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        guard datestringlocalized != "no log" else { return Date()}
        return formatter.date(from: datestringlocalized)!
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
        guard self.snapshotsloggdata?.snapshotslogs != nil else { return }
        for i in 0 ..< self.snapshotsloggdata!.snapshotslogs!.count {
            let index = self.snapshotsloggdata!.snapshotslogs!.count - 1 - i
            if self.currentweek(index: index) {
                self.snapshotsloggdata?.snapshotslogs![index].setValue(0, forKey: "selectCellID")
            } else if self.currentdaymonth(index: index) {
                self.snapshotsloggdata?.snapshotslogs![index].setValue(1, forKey: "selectCellID")
            } else {
                if self.keepallselcteddayofweek == true {
                    if self.previousmonthskeepAllselecteddayofweek(index: index) {
                        self.snapshotsloggdata?.snapshotslogs![index].setValue(1, forKey: "selectCellID")
                    }
                } else {
                    if self.previousmonthskeepLastselecteddayofweek(index: index) {
                        self.snapshotsloggdata?.snapshotslogs![index].setValue(1, forKey: "selectCellID")
                    }
                }
            }
        }
        self.reloadDelegate?.reloadtabledata()
    }

    // Keep all snapshots current week.
    private func currentweek(index: Int) -> Bool {
        let datesnapshotstring = (self.snapshotsloggdata!.snapshotslogs![index].value(forKey: "dateExecuted") as? String)!
        if self.datecomponentsfromstring(datestringlocalized: datesnapshotstring).weekOfYear ==
            self.datecomponentsfromstring(datestringlocalized: self.now).weekOfYear &&
            self.datecomponentsfromstring(datestringlocalized: datesnapshotstring).year ==
            self.datecomponentsfromstring(datestringlocalized: self.now).year {
            let tag = NSLocalizedString("Keep", comment: "plan") + " " + NSLocalizedString("this week", comment: "plan")
            self.snapshotsloggdata?.snapshotslogs![index].setValue(tag, forKey: "period")
            return true
        }
        return false
    }

    // Keep snapshots every choosen day this month ex current week
    private func currentdaymonth(index: Int) -> Bool {
        let datesnapshotstring = (self.snapshotsloggdata!.snapshotslogs![index].value(forKey: "dateExecuted") as? String)!
        let month = self.datefromstring(datestringlocalized: datesnapshotstring).monthNameShort()
        let day = self.datefromstring(datestringlocalized: datesnapshotstring).dayNameShort()
        if self.datecomponentsfromstring(datestringlocalized: datesnapshotstring).month ==
            self.datecomponentsfromstring(datestringlocalized: self.now).month &&
            self.datecomponentsfromstring(datestringlocalized: datesnapshotstring).year == self.datecomponentsfromstring(datestringlocalized: self.now).year {
            if self.datefromstring(datestringlocalized: datesnapshotstring).isSelectedDayofWeek(day: self.day!) == false {
                let tag = NSLocalizedString("Delete", comment: "plan") + " " + day + ", " + month + " " + NSLocalizedString("this month", comment: "plan")
                self.snapshotsloggdata?.snapshotslogs![index].setValue(tag, forKey: "period")
                return true
            } else {
                let tag = NSLocalizedString("Keep", comment: "plan") + " " + month + " " + self.daylocalized[self.day!.rawValue - 1] + " " + NSLocalizedString("this month", comment: "plan")
                self.snapshotsloggdata?.snapshotslogs![index].setValue(tag, forKey: "period")
                return false
            }
        }
        return false
    }

    // Keep snapshots last selected day every previous months
    private func previousmonthskeepLastselecteddayofweek(index: Int) -> Bool {
        let datesnapshotstring = (self.snapshotsloggdata!.snapshotslogs![index].value(forKey: "dateExecuted") as? String)!
        let month = self.datefromstring(datestringlocalized: datesnapshotstring).monthNameShort()
        let day = self.datefromstring(datestringlocalized: datesnapshotstring).dayNameShort()
        if self.datecomponentsfromstring(datestringlocalized: datesnapshotstring).month !=
            self.datecomponentsfromstring(datestringlocalized: self.now).month {
            if self.islastSelectedDayinMonth(date: self.datefromstring(datestringlocalized: datesnapshotstring)) == true {
                let tag = NSLocalizedString("Keep", comment: "plan") + " " + day + ", " + month + " " + NSLocalizedString("last", comment: "plan") + " " + NSLocalizedString("month", comment: "plan")
                self.snapshotsloggdata?.snapshotslogs![index].setValue(tag, forKey: "period")
                return false
            } else {
                let tag = NSLocalizedString("Delete", comment: "plan") + " " + day + ", " + month + " " + NSLocalizedString("prev months", comment: "plan")
                self.snapshotsloggdata?.snapshotslogs![index].setValue(tag, forKey: "period")
                return true
            }
        }
        return false
    }

    // Keep snapshots all selected day every previous months
    private func previousmonthskeepAllselecteddayofweek(index: Int) -> Bool {
        let datesnapshotstring = (self.snapshotsloggdata!.snapshotslogs![index].value(forKey: "dateExecuted") as? String)!
        let month = self.datefromstring(datestringlocalized: datesnapshotstring).monthNameShort()
        let day = self.datefromstring(datestringlocalized: datesnapshotstring).dayNameShort()
        if self.datecomponentsfromstring(datestringlocalized: datesnapshotstring).month !=
            self.datecomponentsfromstring(datestringlocalized: self.now).month {
            if self.isselectedDayinWeek(date: self.datefromstring(datestringlocalized: datesnapshotstring)) == true {
                let tag = NSLocalizedString("Keep", comment: "plan")  + " " + day + ", " + month + " " + NSLocalizedString("prev month", comment: "plan")
                self.snapshotsloggdata?.snapshotslogs![index].setValue(tag, forKey: "period")
                return false
            } else {
                let date = self.datefromstring(datestringlocalized: datesnapshotstring)
                if date.ispreviosmonth() {
                    let tag = NSLocalizedString("Delete", comment: "plan") + " " + day + ", " + month + " " + NSLocalizedString("previous month", comment: "plan")
                    self.snapshotsloggdata?.snapshotslogs![index].setValue(tag, forKey: "period")
                } else {
                    let tag = NSLocalizedString("Delete", comment: "plan") + " " + day + ", " + month + " " + NSLocalizedString("earlier months", comment: "plan")
                    self.snapshotsloggdata?.snapshotslogs![index].setValue(tag, forKey: "period")
                }
                return true
            }
        }
        return false
    }

    func islastSelectedDayinMonth(date: Date) -> Bool {
        if date.isSelectedDayofWeek(day: self.day!) && date.daymonth() > 24 {
            return true
        } else {
            return false
        }
    }

    func isselectedDayinWeek(date: Date) -> Bool {
        return self.day!.rawValue == date.getWeekday()
    }

    private func reset() {
        guard self.snapshotsloggdata?.snapshotslogs != nil else { return }
        for i in 0 ..< self.snapshotsloggdata!.snapshotslogs!.count {
            self.snapshotsloggdata?.snapshotslogs![i].setValue(0, forKey: "selectCellID")
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

    init(plan: Int, snapdayoffweek: String) {
        // which plan to apply
        if plan == 1 {
            self.keepallselcteddayofweek = true
        } else {
            self.keepallselcteddayofweek = false
        }
        self.setweekdaytokeep(snapdayoffweek: snapdayoffweek)
        self.SnapshotsLoggDataDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        self.reloadDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        self.snapshotsloggdata = self.SnapshotsLoggDataDelegate?.getsnapshotsloggdata()
        guard self.snapshotsloggdata?.snapshotslogs != nil else { return }
        self.numberoflogs = self.snapshotsloggdata?.snapshotslogs?.count ?? 0
        self.firstlog = Double(self.snapshotsloggdata?.snapshotslogs![0].value(forKey: "days") as? String ?? "0")
        let dateformatter = DateFormatter()
        dateformatter.formatterBehavior = .behavior10_4
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .short
        self.now = dateformatter.string(from: Date())
        self.reset()
        self.markfordelete()
    }
}

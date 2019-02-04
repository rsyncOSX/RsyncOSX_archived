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
    func getsnapshotsloggaata() -> SnapshotsLoggData?
}

enum Dayofweek: Int {
    case Monday = 2
    case Tuesday = 3
    case Wednesday = 4
    case Thursday = 5
    case Friday = 6
    case Saturday = 7
    case Sunday = 1
}

class PlanSnapshots {

    var day: Dayofweek = .Monday
    var nameofday = "Monday"

    weak var SnapshotsLoggDataDelegate: GetSnapshotsLoggData?
    weak var reloadDelegate: Reloadandrefresh?
    var snapshotsloggdata: SnapshotsLoggData?
    private var numberoflogs: Int?
    private var firstlog: Double?
    private var datecomponentscurrent: DateComponents?
    private var keepallselcteddayofweek: Bool = true

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

    private func datefromstring(datestring: String) -> Date {
        let dateformatter = Dateandtime().setDateformat()
        guard datestring != "no log" else { return Date()}
        return dateformatter.date(from: datestring)!
    }

    private func datecomponentsfromstring(datestring: String?) -> DateComponents {
        var date: Date?
        if datestring == nil {
            date = Date()
        } else {
            date = self.datefromstring(datestring: datestring!)
        }
        let calendar = Calendar.current
        return calendar.dateComponents([.calendar, .timeZone,
                                        .year, .month, .day,
                                        .hour, .minute,
                                        .weekday, .weekOfYear, .year], from: date!)
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
        if self.datecomponentsfromstring(datestring: datesnapshotstring).weekOfYear ==
            self.datecomponentscurrent!.weekOfYear &&
            self.datecomponentsfromstring(datestring: datesnapshotstring).year == self.datecomponentscurrent!.year {
            self.snapshotsloggdata?.snapshotslogs![index].setValue("this week", forKey: "period")
            return true
        }
        return false
    }

    // Keep snapshots every choosen day this month ex current week
    private func currentdaymonth(index: Int) -> Bool {
        let datesnapshotstring = (self.snapshotsloggdata!.snapshotslogs![index].value(forKey: "dateExecuted") as? String)!
        if self.datecomponentsfromstring(datestring: datesnapshotstring).month ==
            self.datecomponentscurrent!.month &&
            self.datecomponentsfromstring(datestring: datesnapshotstring).year == self.datecomponentscurrent!.year {
            if self.datefromstring(datestring: datesnapshotstring).isSelectedDayofWeek(day: self.day) == false {
                self.snapshotsloggdata?.snapshotslogs![index].setValue("this month", forKey: "period")
                return true
            } else {
                self.snapshotsloggdata?.snapshotslogs![index].setValue(self.nameofday + " this month", forKey: "period")
                return false
            }
        }
        return false
    }

    // Keep snapshots last selected day every previous months
    private func previousmonthskeepLastselecteddayofweek(index: Int) -> Bool {
        let datesnapshotstring = (self.snapshotsloggdata!.snapshotslogs![index].value(forKey: "dateExecuted") as? String)!
        if self.datecomponentsfromstring(datestring: datesnapshotstring).month !=
            self.datecomponentscurrent!.month {
            if self.islastSelectedDayinMonth(date: self.datefromstring(datestring: datesnapshotstring)) == true {
                self.snapshotsloggdata?.snapshotslogs![index].setValue("last " + self.nameofday + " month", forKey: "period")
                return false
            } else {
                self.snapshotsloggdata?.snapshotslogs![index].setValue("prev months", forKey: "period")
                return true
            }
        }
        return false
    }

    // Keep snapshots all selected day every previous months
    private func previousmonthskeepAllselecteddayofweek(index: Int) -> Bool {
        let datesnapshotstring = (self.snapshotsloggdata!.snapshotslogs![index].value(forKey: "dateExecuted") as? String)!
        if self.datecomponentsfromstring(datestring: datesnapshotstring).month !=
            self.datecomponentscurrent!.month {
            if self.isselectedDayinWeek(date: self.datefromstring(datestring: datesnapshotstring)) == true {
                self.snapshotsloggdata?.snapshotslogs![index].setValue(self.nameofday + " prev months", forKey: "period")
                return false
            } else {
                self.snapshotsloggdata?.snapshotslogs![index].setValue("prev months", forKey: "period")
                return true
            }
        }
        return false
    }

    func islastSelectedDayinMonth(date: Date) -> Bool {
        if date.isSelectedDayofWeek(day: self.day) && date.daymonth() > 24 {
            return true
        } else {
            return false
        }
    }

    func isselectedDayinWeek(date: Date) -> Bool {
        return self.day.rawValue == date.getWeekday()
    }

    private func reset() {
        guard self.snapshotsloggdata?.snapshotslogs != nil else { return }
        for i in 0 ..< self.snapshotsloggdata!.snapshotslogs!.count {
            self.snapshotsloggdata?.snapshotslogs![i].setValue(0, forKey: "selectCellID")
        }
    }

    init(plan: Int) {
        if plan == 1 {
            self.keepallselcteddayofweek = false
        } else {
            self.keepallselcteddayofweek = true
        }
        self.SnapshotsLoggDataDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        self.reloadDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        self.snapshotsloggdata = self.SnapshotsLoggDataDelegate?.getsnapshotsloggaata()
        guard self.snapshotsloggdata?.snapshotslogs != nil else { return }
        self.numberoflogs = self.snapshotsloggdata?.snapshotslogs?.count ?? 0
        self.firstlog = Double(self.snapshotsloggdata?.snapshotslogs![0].value(forKey: "days") as? String ?? "0")
        self.datecomponentscurrent = self.datecomponentsfromstring(datestring: nil)
        self.reset()
        self.markfordelete()
    }
}

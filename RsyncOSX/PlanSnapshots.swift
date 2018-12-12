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

class PlanSnapshots {

    weak var SnapshotsLoggDataDelegate: GetSnapshotsLoggData?
    weak var reloadDelegate: Reloadandrefresh?
    var snapshotsloggdata: SnapshotsLoggData?
    private var numberoflogs: Int?
    private var firstlog: Double?
    private var datecomponentscurrent: DateComponents?

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
                                        .weekday, .weekOfYear, .yearForWeekOfYear], from: date!)
    }

    // let dateStart: Date = dateformatter.date(from: (dict.value(forKey: "dateStart") as? String)!)!
    // let filter = self.snapshotsloggdata!.snapshotslogs!.filter({$0.value( forKey: "select") as? Int == 1})
    private func markfordelete() {
        guard self.snapshotsloggdata?.snapshotslogs != nil else { return }
        for i in 0 ..< self.snapshotsloggdata!.snapshotslogs!.count {
            let index = self.snapshotsloggdata!.snapshotslogs!.count - 1 - i
            if self.currentweek(index: index) {
                self.snapshotsloggdata?.snapshotslogs![index].setValue(0, forKey: "selectCellID")
            } else if self.currentmonth(index: index) {
                self.snapshotsloggdata?.snapshotslogs![index].setValue(1, forKey: "selectCellID")
            } else if self.previousmonths(index: index) {
                self.snapshotsloggdata?.snapshotslogs![index].setValue(1, forKey: "selectCellID")
            }
        }
        self.reloadDelegate?.reloadtabledata()
    }

    private func currentweek(index: Int) -> Bool {
        let datesnapshotstring = (self.snapshotsloggdata!.snapshotslogs![index].value(forKey: "dateExecuted") as? String)!
        if self.datecomponentsfromstring(datestring: datesnapshotstring).weekOfYear ==
            self.datecomponentscurrent!.weekOfYear &&
            self.datecomponentsfromstring(datestring: datesnapshotstring).yearForWeekOfYear == self.datecomponentscurrent!.yearForWeekOfYear {
            self.snapshotsloggdata?.snapshotslogs![index].setValue("current", forKey: "day")
            return true
        }
        return false
    }

    private func currentmonth(index: Int) -> Bool {
        let datesnapshotstring = (self.snapshotsloggdata!.snapshotslogs![index].value(forKey: "dateExecuted") as? String)!
        if self.datecomponentsfromstring(datestring: datesnapshotstring).month ==
            self.datecomponentscurrent!.month &&
            self.datecomponentsfromstring(datestring: datesnapshotstring).yearForWeekOfYear == self.datecomponentscurrent!.yearForWeekOfYear {
            if self.datefromstring(datestring: datesnapshotstring).isWeekday() {
                self.snapshotsloggdata?.snapshotslogs![index].setValue("weekday", forKey: "day")
                return true
            }
        }
        return false
    }

    private func previousmonths(index: Int) -> Bool {
        let datesnapshotstring = (self.snapshotsloggdata!.snapshotslogs![index].value(forKey: "dateExecuted") as? String)!
        if self.datecomponentsfromstring(datestring: datesnapshotstring).month !=
            self.datecomponentscurrent!.month &&
            self.datecomponentsfromstring(datestring: datesnapshotstring).yearForWeekOfYear == self.datecomponentscurrent!.yearForWeekOfYear {
            if self.datefromstring(datestring: datesnapshotstring).isWeekday() {
                self.snapshotsloggdata?.snapshotslogs![index].setValue("weekday", forKey: "day")
                return true
            }
        }
        return false
    }

    init() {
        self.SnapshotsLoggDataDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        self.reloadDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        self.snapshotsloggdata = self.SnapshotsLoggDataDelegate?.getsnapshotsloggaata()
        guard self.snapshotsloggdata?.snapshotslogs != nil else { return }
        self.numberoflogs = self.snapshotsloggdata?.snapshotslogs?.count ?? 0
        self.firstlog = Double(self.snapshotsloggdata?.snapshotslogs![0].value(forKey: "days") as? String ?? "0")
        self.datecomponentscurrent = self.datecomponentsfromstring(datestring: nil)
        self.markfordelete()
    }
}

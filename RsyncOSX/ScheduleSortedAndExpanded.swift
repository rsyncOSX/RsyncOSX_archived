//
//  ScheduleSortedAndExpanded.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length trailing_comma cyclomatic_complexity function_body_length

import Cocoa
import Foundation

class ScheduleSortedAndExpand: SetConfigurations, SetSchedules {
    private var schedulesNSDictionary: [NSDictionary]?
    private var scheduleConfiguration: [ConfigurationSchedule]?
    private var expandedData: [NSDictionary]?
    private var sortedschedules: [NSDictionary]?
    var delta: [String]?

    // Calculate daily schedules
    private func daily(dateStart: Date, schedule: String, dict: NSDictionary) {
        let cal = Calendar.current
        if let start: Date = cal.date(byAdding: dateStart.dayssincenow, to: dateStart) {
            if start.timeIntervalSinceNow > 0 {
                let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
                let profilename = dict.value(forKey: "profilename") ?? NSLocalizedString("Default profile", comment: "default profile")
                let time = start.timeIntervalSinceNow
                let dictSchedule: NSDictionary = [
                    "start": start,
                    "hiddenID": hiddenID,
                    "dateStart": dateStart,
                    "schedule": schedule,
                    "timetostart": time,
                    "profilename": profilename,
                ]
                self.expandedData?.append(dictSchedule)
            }
        }
    }

    // Calculate weekly schedules
    private func weekly(dateStart: Date, schedule: String, dict: NSDictionary) {
        let cal = Calendar.current
        if let start: Date = cal.date(byAdding: dateStart.weekssincenowplusoneweek, to: dateStart) {
            if start.timeIntervalSinceNow > 0 {
                let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
                let profilename = dict.value(forKey: "profilename") ?? NSLocalizedString("Default profile", comment: "default profile")
                let time = start.timeIntervalSinceNow
                let dictSchedule: NSDictionary = [
                    "start": start,
                    "hiddenID": hiddenID,
                    "dateStart": dateStart,
                    "schedule": schedule,
                    "timetostart": time,
                    "profilename": profilename,
                ]
                self.expandedData?.append(dictSchedule)
            }
        }
    }

    // Expanding and sorting Scheduledata
    private func sortAndExpandScheduleTasks() {
        for i in 0 ..< (self.schedulesNSDictionary?.count ?? 0) {
            let dict = self.schedulesNSDictionary![i]
            let dateStop: Date = (dict.value(forKey: "dateStop") as? String)!.en_us_date_from_string()
            let dateStart: Date = (dict.value(forKey: "dateStart") as? String)!.en_us_date_from_string()
            let schedule: String = (dict.value(forKey: "schedule") as? String)!
            let seconds: Double = dateStop.timeIntervalSinceNow
            // Get all jobs which are not executed
            if seconds > 0 {
                switch schedule {
                case Scheduletype.once.rawValue:
                    let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
                    let profilename = dict.value(forKey: "profilename") ?? NSLocalizedString("Default profile", comment: "default profile")
                    let time = seconds
                    let dict: NSDictionary = [
                        "start": dateStart,
                        "hiddenID": hiddenID,
                        "dateStart": dateStart,
                        "schedule": schedule,
                        "timetostart": time,
                        "profilename": profilename,
                    ]
                    self.expandedData?.append(dict)
                case Scheduletype.daily.rawValue:
                    self.daily(dateStart: dateStart, schedule: schedule, dict: dict)
                case Scheduletype.weekly.rawValue:
                    self.weekly(dateStart: dateStart, schedule: schedule, dict: dict)
                default:
                    break
                }
            }
            self.sortedschedules = self.expandedData?.sorted { (date1, date2) -> Bool in
                if let date1 = date1.value(forKey: "start") as? Date {
                    if let date2 = date2.value(forKey: "start") as? Date {
                        if date1.timeIntervalSince(date2) > 0 {
                            return false
                        } else {
                            return true
                        }
                    }
                }
                return false
            }
        }
    }

    private func adddelta() {
        // calculate delta time
        self.delta = [String]()
        self.delta?.append("0")
        let timestring = Dateandtime()
        for i in 1 ..< (self.sortedschedules?.count ?? 0) {
            if let t1 = self.sortedschedules?[i - 1].value(forKey: "timetostart") as? Double {
                if let t2 = self.sortedschedules?[i].value(forKey: "timetostart") as? Double {
                    self.delta?.append(timestring.timestring(seconds: t2 - t1))
                }
            }
        }
    }

    typealias Futureschedules = (Int, Double)

    // Calculates number of future Schedules ID by hiddenID
    func numberoftasks(_ hiddenID: Int) -> Futureschedules {
        let result = self.sortedschedules?.filter { (($0.value(forKey: "hiddenID") as? Int)! == hiddenID) }
        guard result?.count ?? 0 > 0 else { return (0, 0) }
        let timetostart = result![0].value(forKey: "timetostart") as? Double ?? 0
        return (result!.count, timetostart)
    }

    func sortandcountscheduledonetask(_ hiddenID: Int, profilename: String?, number: Bool) -> String {
        var result: [NSDictionary]?
        if profilename != nil {
            result = self.sortedschedules?.filter { (($0.value(forKey: "hiddenID") as? Int)! == hiddenID
                    && ($0.value(forKey: "start") as? Date)!.timeIntervalSinceNow > 0)
                && ($0.value(forKey: "profilename") as? String)! == profilename!
            }
        } else {
            result = self.sortedschedules?.filter { (($0.value(forKey: "hiddenID") as? Int)! == hiddenID
                    && ($0.value(forKey: "start") as? Date)!.timeIntervalSinceNow > 0) }
        }
        guard result != nil else { return "" }
        let sorted = result!.sorted { (di1, di2) -> Bool in
            if (di1.value(forKey: "start") as? Date)!.timeIntervalSince((di2.value(forKey: "start") as? Date)!) > 0 {
                return false
            } else {
                return true
            }
        }
        guard sorted.count > 0 else { return "" }
        if number {
            let firsttask = (sorted[0].value(forKey: "start") as? Date)?.timeIntervalSinceNow
            return Dateandtime().timestring(seconds: firsttask!)
        } else {
            let type = sorted[0].value(forKey: "schedule") as? String
            return type ?? ""
        }
    }

    /// Function is reading Schedule plans and transform plans to
    /// array of NSDictionary.
    /// - returns : none
    private func setallscheduledtasksNSDictionary() {
        var data = [NSDictionary]()
        for i in 0 ..< (self.scheduleConfiguration?.count ?? 0) where
            self.scheduleConfiguration![i].dateStop != nil && self.scheduleConfiguration![i].schedule != Scheduletype.stopped.rawValue {
            let dict: NSDictionary = [
                "dateStart": self.scheduleConfiguration?[i].dateStart ?? "",
                "dateStop": self.scheduleConfiguration?[i].dateStop ?? "",
                "hiddenID": self.scheduleConfiguration?[i].hiddenID ?? -1,
                "schedule": self.scheduleConfiguration?[i].schedule ?? "",
                "profilename": self.scheduleConfiguration![i].profilename ?? NSLocalizedString("Default profile", comment: "default profile"),
            ]
            data.append(dict as NSDictionary)
        }
        self.schedulesNSDictionary = data
    }

    init() {
        // Getting the Schedule and expanding all the jobs
        guard self.schedules != nil else { return }
        self.expandedData = [NSDictionary]()
        self.scheduleConfiguration = self.schedules?.getSchedule()
        self.setallscheduledtasksNSDictionary()
        self.sortAndExpandScheduleTasks()
    }

    init(allschedules: Allschedules?) {
        guard allschedules != nil else { return }
        self.expandedData = [NSDictionary]()
        self.scheduleConfiguration = allschedules?.getallschedules()
        self.setallscheduledtasksNSDictionary()
        self.sortAndExpandScheduleTasks()
    }

    // For XCtest
    init(schedules: Schedules?) {
        self.expandedData = [NSDictionary]()
        self.scheduleConfiguration = schedules?.getSchedule()
        self.setallscheduledtasksNSDictionary()
        self.sortAndExpandScheduleTasks()
    }
}

//
//  ScheduleSortedAndExpanded.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length trailing_comma

import Cocoa
import Foundation

class ScheduleSortedAndExpand: SetConfigurations, SetSchedules {
    var schedulesNSDictionary: [NSMutableDictionary]?
    var scheduleConfiguration: [ConfigurationSchedule]?
    var expandedData: [NSMutableDictionary]?
    var sortedschedules: [NSMutableDictionary]?

    // Calculate daily schedules
    private func daily(dateStart: Date, schedule: String, dict: NSDictionary) {
        let calendar = Calendar.current
        var days: Int?
        if dateStart.daystonow == Date().daystonow, dateStart > Date() {
            days = dateStart.daystonow
        } else {
            days = dateStart.daystonow + 1
        }
        let components = DateComponents(day: days)
        if let start: Date = calendar.date(byAdding: components, to: dateStart) {
            if start.timeIntervalSinceNow > 0 {
                if let hiddenID = (dict.value(forKey: "hiddenID") as? Int) {
                    let profilename = dict.value(forKey: "profilename") ?? NSLocalizedString("Default profile", comment: "default profile")
                    let time = start.timeIntervalSinceNow
                    let dictschedule: NSMutableDictionary = [
                        "start": start,
                        "hiddenID": hiddenID,
                        "dateStart": dateStart,
                        "schedule": schedule,
                        "timetostart": time,
                        "profilename": profilename,
                    ]
                    self.expandedData?.append(dictschedule)
                }
            }
        }
    }

    // Calculate weekly schedules
    private func weekly(dateStart: Date, schedule: String, dict: NSDictionary) {
        let calendar = Calendar.current
        var weekofyear: Int?
        if dateStart.weekstonow == Date().weekstonow, dateStart > Date() {
            weekofyear = dateStart.weekstonow
        } else {
            weekofyear = dateStart.weekstonow + 1
        }
        let components = DateComponents(weekOfYear: weekofyear)
        if let start: Date = calendar.date(byAdding: components, to: dateStart) {
            if start.timeIntervalSinceNow > 0 {
                if let hiddenID = (dict.value(forKey: "hiddenID") as? Int) {
                    let profilename = dict.value(forKey: "profilename") ?? NSLocalizedString("Default profile", comment: "default profile")
                    let time = start.timeIntervalSinceNow
                    let dictschedule: NSMutableDictionary = [
                        "start": start,
                        "hiddenID": hiddenID,
                        "dateStart": dateStart,
                        "schedule": schedule,
                        "timetostart": time,
                        "profilename": profilename,
                    ]
                    self.expandedData?.append(dictschedule)
                }
            }
        }
    }

    // Expanding and sorting Scheduledata
    private func sortAndExpandScheduleTasks() {
        for i in 0 ..< (self.schedulesNSDictionary?.count ?? 0) {
            let dict = self.schedulesNSDictionary![i]
            let dateStop: Date = (dict.value(forKey: "dateStop") as? String)?.en_us_date_from_string() ?? Date()
            let dateStart: Date = (dict.value(forKey: "dateStart") as? String)?.en_us_date_from_string() ?? Date()
            let schedule: String = (dict.value(forKey: "schedule") as? String) ?? Scheduletype.once.rawValue
            let seconds: Double = dateStop.timeIntervalSinceNow
            // Get all jobs which are not executed
            if seconds > 0 {
                switch schedule {
                case Scheduletype.once.rawValue:
                    if let hiddenID = (dict.value(forKey: "hiddenID") as? Int) {
                        let profilename = dict.value(forKey: "profilename") ?? NSLocalizedString("Default profile", comment: "default profile")
                        let time = seconds
                        let dictschedule: NSMutableDictionary = [
                            "start": dateStart,
                            "hiddenID": hiddenID,
                            "dateStart": dateStart,
                            "schedule": schedule,
                            "timetostart": time,
                            "profilename": profilename,
                        ]
                        self.expandedData?.append(dictschedule)
                    }
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
        self.adddelta()
    }

    private func adddelta() {
        // calculate delta time
        guard (self.sortedschedules?.count ?? 0) > 1 else { return }
        let timestring = Dateandtime()
        self.sortedschedules?[0].setValue(timestring.timestring(seconds: 0), forKey: "delta")
        if let timetostart = self.sortedschedules?[0].value(forKey: "timetostart") as? Double {
            self.sortedschedules?[0].setValue(timestring.timestring(seconds: timetostart), forKey: "startsin")
        }
        self.sortedschedules?[0].setValue(0, forKey: "queuenumber")
        for i in 1 ..< (self.sortedschedules?.count ?? 0) {
            if let t1 = self.sortedschedules?[i - 1].value(forKey: "timetostart") as? Double {
                if let t2 = self.sortedschedules?[i].value(forKey: "timetostart") as? Double {
                    self.sortedschedules?[i].setValue(timestring.timestring(seconds: t2 - t1), forKey: "delta")
                    self.sortedschedules?[i].setValue(i, forKey: "queuenumber")
                    self.sortedschedules?[i].setValue(timestring.timestring(seconds: t2), forKey: "startsin")
                }
            }
        }
    }

    typealias Futureschedules = (Int, Double)

    // Calculates number of future Schedules ID by hiddenID
    func numberoftasks(_ hiddenID: Int) -> Futureschedules {
        if let result = self.sortedschedules?.filter({ (($0.value(forKey: "hiddenID") as? Int) == hiddenID) }) {
            guard result.count > 0 else { return (0, 0) }
            let timetostart = result[0].value(forKey: "timetostart") as? Double ?? 0
            return (result.count, timetostart)
        }
        return (0, 0)
    }

    func sortandcountscheduledonetask(_ hiddenID: Int, profilename: String?, number: Bool) -> String {
        var result: [NSDictionary]?
        if profilename != nil {
            result = self.sortedschedules?.filter { (($0.value(forKey: "hiddenID") as? Int) == hiddenID
                    && ($0.value(forKey: "start") as? Date)?.timeIntervalSinceNow ?? -1 > 0)
                && ($0.value(forKey: "profilename") as? String) == profilename ?? ""
            }
        } else {
            result = self.sortedschedules?.filter { (($0.value(forKey: "hiddenID") as? Int) == hiddenID
                    && ($0.value(forKey: "start") as? Date)?.timeIntervalSinceNow ?? -1 > 0) }
        }
        guard result != nil else { return "" }
        let sorted = result?.sorted { (di1, di2) -> Bool in
            if let d1 = di1.value(forKey: "start") as? Date, let d2 = di2.value(forKey: "start") as? Date {
                if d1.timeIntervalSince(d2) > 0 {
                    return false
                } else {
                    return true
                }
            }
            return false
        }
        guard (sorted?.count ?? 0) > 0 else { return "" }
        if number {
            if let firsttask = (sorted?[0].value(forKey: "start") as? Date)?.timeIntervalSinceNow {
                return Dateandtime().timestring(seconds: firsttask)
            } else {
                return ""
            }
        } else {
            let type = sorted?[0].value(forKey: "schedule") as? String
            return type ?? ""
        }
    }

    /// Function is reading Schedule plans and transform plans to
    /// array of NSDictionary.
    /// - returns : none
    private func setallscheduledtasksNSDictionary() {
        var data = [NSMutableDictionary]()
        let scheduletypes: Set<String> = [Scheduletype.daily.rawValue, Scheduletype.weekly.rawValue, Scheduletype.once.rawValue]
        for i in 0 ..< (self.scheduleConfiguration?.count ?? 0) where
            self.scheduleConfiguration?[i].dateStop != nil && scheduletypes.contains(self.scheduleConfiguration?[i].schedule ?? "")
        {
            let dict: NSMutableDictionary = [
                "dateStart": self.scheduleConfiguration?[i].dateStart ?? "",
                "dateStop": self.scheduleConfiguration?[i].dateStop ?? "",
                "hiddenID": self.scheduleConfiguration?[i].hiddenID ?? -1,
                "schedule": self.scheduleConfiguration?[i].schedule ?? "",
                "profilename": self.scheduleConfiguration![i].profilename ?? NSLocalizedString("Default profile", comment: "default profile"),
            ]
            data.append(dict as NSMutableDictionary)
        }
        self.schedulesNSDictionary = data
    }

    init() {
        // Getting the Schedule and expanding all the jobs
        guard self.schedules != nil else { return }
        self.expandedData = [NSMutableDictionary]()
        self.scheduleConfiguration = self.schedules?.getSchedule()
        self.setallscheduledtasksNSDictionary()
        self.sortAndExpandScheduleTasks()
    }

    init(allschedules: Allschedules?) {
        guard allschedules != nil else { return }
        self.expandedData = [NSMutableDictionary]()
        self.scheduleConfiguration = allschedules?.getallschedules()
        self.setallscheduledtasksNSDictionary()
        self.sortAndExpandScheduleTasks()
    }

    // For XCtest
    init(schedules: Schedules?) {
        self.expandedData = [NSMutableDictionary]()
        self.scheduleConfiguration = schedules?.getSchedule()
        self.setallscheduledtasksNSDictionary()
        self.sortAndExpandScheduleTasks()
    }
}

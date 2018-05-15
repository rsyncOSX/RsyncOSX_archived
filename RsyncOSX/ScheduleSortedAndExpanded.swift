//
//  ScheduleSortedAndExpanded.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ScheduleSortedAndExpand: SetConfigurations, SetSchedules {

    // Reference to main View
    private var vctabmain: NSViewController?
    private var schedulesNSDictionary: [NSDictionary]?
    private var scheduleConfiguration: [ConfigurationSchedule]?
    private var expandedData = [NSDictionary]()
    private var sortedschedules: [NSDictionary]?
    private var scheduleInProgress: Bool = false
    private var tools: Tools?

    // First job to execute. Job is first element in
    func firstscheduledtask() -> NSDictionary? {
        guard self.sortedschedules != nil else { return nil}
        guard self.sortedschedules!.count > 0 else {
            ViewControllerReference.shared.scheduledTask = nil
            return nil
        }
        return self.sortedschedules![0]
    }

    // Returns reference to all sorted and expanded schedules
    func getsortedAndExpandedScheduleData() -> [NSDictionary]? {
        return self.sortedschedules
    }

    // Calculate daily schedules
    private func daily(dateStart: Date, schedule: String, dict: NSDictionary) {
        var i = 0
        while self.nextdayorweekindex(dateStart: dateStart, day: i, schedule: schedule) < 0 && i < 1000 { i += 1 }
        var dateComponent = DateComponents()
        dateComponent.day = i
        let cal = Calendar.current
        if let start: Date = cal.date(byAdding: dateComponent, to: dateStart) {
            if start.timeIntervalSinceNow > 0 {
                let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
                let profilename = dict.value(forKey: "profilename") ?? "Default profile"
                let time = start.timeIntervalSinceNow
                let dictSchedule: NSDictionary = [
                    "start": start,
                    "hiddenID": hiddenID,
                    "dateStart": dateStart,
                    "schedule": schedule,
                    "timetostart": time,
                    "profilename": profilename]
                self.expandedData.append(dictSchedule)
            }
        }
    }

    // Calculate weekly schedules
    private func weekly(dateStart: Date, schedule: String, dict: NSDictionary) {
        var i = 0
        while self.nextdayorweekindex(dateStart: dateStart, day: i, schedule: schedule) < 0 && i < 1000 { i += 1 }
        var dateComponent = DateComponents()
        dateComponent.day = (i * 7)
        let cal = Calendar.current
        if let start: Date = cal.date(byAdding: dateComponent, to: dateStart) {
            if start.timeIntervalSinceNow > 0 {
                let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
                let profilename = dict.value(forKey: "profilename") ?? "Default profile"
                let time = start.timeIntervalSinceNow
                let dictSchedule: NSDictionary = [
                    "start": start,
                    "hiddenID": hiddenID,
                    "dateStart": dateStart,
                    "schedule": schedule,
                    "timetostart": time,
                    "profilename": profilename]
                self.expandedData.append(dictSchedule)
            }
        }
    }

    private func nextdayorweekindex(dateStart: Date, day: Int, schedule: String) -> Int {
        var dateComponent = DateComponents()
        switch schedule {
        case "daily":
            dateComponent.day = day
        case "weekly":
            dateComponent.day = (day * 7)
        default:
            dateComponent.day = (day * 7)
        }
        let cal = Calendar.current
        if let start: Date = cal.date(byAdding: dateComponent, to: dateStart) {
            if start.timeIntervalSinceNow > 0 {
                return day
            } else {
                return -1
            }
        }
        return -1
    }

    // Expanding and sorting Scheduledata
    private func sortAndExpandScheduleTasks() {
        let dateformatter = Tools().setDateformat()
        for i in 0 ..< self.schedulesNSDictionary!.count {
            let dict = self.schedulesNSDictionary![i]
            let dateStop: Date = dateformatter.date(from: (dict.value(forKey: "dateStop") as? String)!)!
            let dateStart: Date = dateformatter.date(from: (dict.value(forKey: "dateStart") as? String)!)!
            let schedule: String = (dict.value(forKey: "schedule") as? String)!
            let seconds: Double = dateStop.timeIntervalSinceNow
            // Get all jobs which are not executed
            if seconds > 0 {
                switch schedule {
                case "once" :
                    let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
                    let profilename = dict.value(forKey: "profilename") ?? "Default profile"
                    let time = seconds
                    let dict: NSDictionary = [
                        "start": dateStart,
                        "hiddenID": hiddenID,
                        "dateStart": dateStart,
                        "schedule": schedule,
                        "timetostart": time,
                        "profilename": profilename]
                    self.expandedData.append(dict)
                case "daily":
                    self.daily(dateStart: dateStart, schedule: schedule, dict: dict)
                case "weekly":
                    self.weekly(dateStart: dateStart, schedule: schedule, dict: dict)
                default:
                    break
                }
            }
            self.sortedschedules = self.expandedData.sorted { (di1, di2) -> Bool in
                if (di1.value(forKey: "start") as? Date)!.timeIntervalSince((di2.value(forKey: "start") as? Date)!)>0 {
                    return false
                } else {
                    return true
                }
            }
        }
    }

    typealias Futureschedules = (Int, Double)

    // Calculates number of future Schedules ID by hiddenID
    func numberoftasks (_ hiddenID: Int) -> Futureschedules {
        let result = self.sortedschedules?.filter({return (($0.value(forKey: "hiddenID") as? Int)! == hiddenID)})
        guard result?.count ?? 0 > 0 else { return (0, 0)}
        let timetostart = result![0].value(forKey: "timetostart" ) as? Double ?? 0
        return (result!.count, timetostart)
    }

    func sortandcountscheduledonetask (_ hiddenID: Int, number: Bool) -> String {
        if let result = self.sortedschedules?.filter({return (($0.value(forKey: "hiddenID") as? Int)! == hiddenID
            && ($0.value(forKey: "start") as? Date)!.timeIntervalSinceNow > 0 )}) {
            let sorted = result.sorted {(di1, di2) -> Bool in
                if (di1.value(forKey: "start") as? Date)!.timeIntervalSince((di2.value(forKey: "start") as? Date)!)>0 {
                    return false
                } else {
                    return true
                }
            }
            guard sorted.count > 0 else { return "" }
            if number {
                let firsttask = (sorted[0].value(forKey: "start") as? Date)?.timeIntervalSinceNow
                return self.tools?.timeString(firsttask!) ?? ""
            } else {
                let type = sorted[0].value(forKey: "schedule") as? String
                return type ?? ""
            }
        } else {
            return ""
        }
    }

    /// Function is reading Schedule plans and transform plans to
    /// array of NSDictionary.
    /// - returns : none
    private func setallscheduledtasksNSDictionary () {
        guard self.scheduleConfiguration != nil else {
            return
        }
        var data = [NSDictionary]()
        for i in 0 ..< self.scheduleConfiguration!.count where
            self.scheduleConfiguration![i].dateStop != nil && self.scheduleConfiguration![i].schedule != "stopped" {
                let dict: NSDictionary = [
                    "dateStart": self.scheduleConfiguration![i].dateStart,
                    "dateStop": self.scheduleConfiguration![i].dateStop!,
                    "hiddenID": self.scheduleConfiguration![i].hiddenID,
                    "schedule": self.scheduleConfiguration![i].schedule
                ]
                data.append(dict as NSDictionary)
            }
        self.schedulesNSDictionary = data
    }

    init () {
        // Getting the Schedule and expanding all the jobs
        if self.schedules != nil {
            self.scheduleConfiguration = self.schedules!.getSchedule()
            self.setallscheduledtasksNSDictionary()
            self.sortAndExpandScheduleTasks()
        }
        self.tools = Tools()
    }

    init (allschedules: Allschedules?) {
        guard allschedules != nil else { return }
        self.scheduleConfiguration = allschedules!.getallschedules()
        self.setallscheduledtasksNSDictionary()
        self.sortAndExpandScheduleTasks()
        self.tools = Tools()
    }
}

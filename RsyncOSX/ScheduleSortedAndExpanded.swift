//
//  ScheduleSortedAndExpanded.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//  swiftlint More work to fix - 17 July 2017
//
//  swiftlint:disable syntactic_sugar

import Foundation
import Cocoa

class ScheduleSortedAndExpand: SetConfigurations, SetSchedules {

    // Reference to main View
    private var vctabmain: NSViewController?
    private var schedulesNSDictionary: Array<NSDictionary>?
    private var scheduleConfiguration: Array<ConfigurationSchedule>?
    private var expandedData = Array<NSDictionary>()
    private var sortedschedules: Array<NSDictionary>?
    private var scheduleInProgress: Bool = false
    private var tools: Tools?

    // First job to execute.Job is first element in 
    func allscheduledtasks() -> NSDictionary? {
        guard self.sortedschedules != nil else { return nil}
        guard self.sortedschedules!.count > 0 else {
            ViewControllerReference.shared.scheduledTask = nil
            return nil
        }
        return self.sortedschedules![0]
    }

    // Returns reference to all sorted and expanded schedules
    func getsortedAndExpandedScheduleData() -> Array<NSDictionary>? {
        return self.sortedschedules
    }

    // Calculate daily schedules
    private func daily (days: Double, dateStart: Date, schedule: String, dict: NSDictionary) {
        var k = Int(days)
        if k > 30 { k = 30 }
        for j in 0 ..< k {
            var dateComponent = DateComponents()
            dateComponent.day = j+1
            let cal = Calendar.current
            if let start: Date = cal.date(byAdding: dateComponent, to: dateStart) {
                if start.timeIntervalSinceNow > 0 {
                    let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
                    let dictSchedule: NSDictionary = [
                        "start": start,
                        "hiddenID": hiddenID,
                        "dateStart": dateStart,
                        "schedule": schedule]
                    self.expandedData.append(dictSchedule)
                }
            }
        }
    }

    // Calculate weekly schedules
    private func weekly (days: Double, dateStart: Date, schedule: String, dict: NSDictionary) {
        var k = Int(days)
        if k > 30 { k = 30 }
        for j in 0 ..< Int(k/7) {
            var dateComponent = DateComponents()
            dateComponent.day = ((j+1)*7)
            let cal = Calendar.current
            if let start: Date = cal.date(byAdding: dateComponent, to: dateStart) {
                if start.timeIntervalSinceNow > 0 {
                    let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
                    let dictSchedule: NSDictionary = [
                        "start": start,
                        "hiddenID": hiddenID,
                        "dateStart": dateStart,
                        "schedule": schedule]
                    self.expandedData.append(dictSchedule)
                }
            }
        }
    }

    // Expanding and sorting Scheduledata
    private func sortAndExpandScheduleTasks() {
        let dateformatter = Tools().setDateformat()
        for i in 0 ..< self.schedulesNSDictionary!.count {
            let dict = self.schedulesNSDictionary![i]
            let dateStop: Date = dateformatter.date(from: (dict.value(forKey: "dateStop") as? String)!)!
            let dateStart: Date = dateformatter.date(from: (dict.value(forKey: "dateStart") as? String)!)!
            let days: Double = dateStop.timeIntervalSinceNow/(60*60*24)
            let schedule: String = (dict.value(forKey: "schedule") as? String)!
            let seconds: Double = dateStop.timeIntervalSinceNow
            // Get all jobs which are not executed
            if seconds > 0 {
                switch schedule {
                case "once" :
                    let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
                    let dict: NSDictionary = [
                        "start": dateStop,
                        "hiddenID": hiddenID,
                        "dateStart": dateStart,
                        "schedule": schedule]
                    self.expandedData.append(dict)
                case "daily":
                    self.daily(days: days, dateStart: dateStart, schedule: schedule, dict: dict)
                case "weekly":
                    self.weekly(days: days, dateStart: dateStart, schedule: schedule, dict: dict)
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

    // Calculates number of future Schedules ID by hiddenID
    func countscheduledtasks (_ hiddenID: Int) -> Int {
        if let result = self.sortedschedules?.filter({return (($0.value(forKey: "hiddenID") as? Int)! == hiddenID
            && ($0.value(forKey: "start") as? Date)!.timeIntervalSinceNow > 0 )}) {
            return result.count
        } else {
            return 0
        }
    }

    func sortandcountscheduledtasks (_ hiddenID: Int) -> String {
        if let result = self.sortedschedules?.filter({return (($0.value(forKey: "hiddenID") as? Int)! == hiddenID
            && ($0.value(forKey: "start") as? Date)!.timeIntervalSinceNow > 0 )}) {
            let sorted = result.sorted {(di1, di2) -> Bool in
                if (di1.value(forKey: "start") as? Date)!.timeIntervalSince((di2.value(forKey: "start") as? Date)!)>0 {
                    return false
                } else {
                    return true
                }
            }
            guard sorted.count > 0 else {
                return ""
            }
            let firsttask = (sorted[0].value(forKey: "start") as? Date)?.timeIntervalSinceNow
            let tst = self.tools?.timeString(firsttask!)
            return tst ?? ""
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
        var data = Array<NSDictionary>()
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
}

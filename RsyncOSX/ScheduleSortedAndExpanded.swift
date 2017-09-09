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

class ScheduleSortedAndExpand {

    // configurationsNoS
    weak var configurationsDelegate: GetConfigurationsObject?
    var configurationsNoS: Configurations?
    weak var schedulesDelegate: GetSchedulesObject?
    var schedulesNoS: SchedulesNoS?
    // configurationsNoS

    // DATA STRUCTURES

    // Array to store all scheduled jobs and history of executions
    // Will be kept in memory until destroyed
    private var schedulesNSDictionary: Array<NSDictionary>?
    private var scheduleConfiguration: Array<ConfigurationSchedule>?
    // Unsorted expanded data
    private var expandedData = Array<NSDictionary>()
    // Sorting and expanding Schedule data.
    private var sortedschedules: Array<NSDictionary>?
    // Schedule in progress
    private var scheduleInProgress: Bool = false

    // First job to execute.Job is first element in 
    func jobToExecute() -> NSDictionary? {
        guard self.sortedschedules != nil else { return nil}
        guard self.sortedschedules!.count > 0 else {return nil}
        return self.sortedschedules![0]
    }

    // Returns reference to all sorted and expanded schedules
    func getsortedAndExpandedScheduleData() -> Array<NSDictionary>? {
        return self.sortedschedules
    }

    // True if scheduled process is about to start
    func getScheduledOperationInProgress() -> Bool {
        // Calculate next schedule in progress
        if self.whenIsNextTwoTasksDouble()[0] > 0 {
        } else {
            self.scheduleInProgress = false
        }
        return self.scheduleInProgress
    }

    // Calculate daily schedules
    private func daily (days: Double, dateStart: Date, schedule: String, dict: NSDictionary) {
        var k = Int(days)
        if k < 370 {
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
    }

    // Calculate weekly schedules
    private func weekly (days: Double, dateStart: Date, schedule: String, dict: NSDictionary) {
        var k = Int(days)
        if k < 370 {
            if k > 30 {k = 30}
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
    }

    // Expanding and sorting Scheduledata
    private func sortAndExpandScheduleData() {
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
        // Set reference to the first scheduled job
        self.schedulesNoS!.scheduledJob = self.jobToExecute()
        }
    }

    // Calculates number of future Schedules ID by hiddenID
    func numberOfFutureSchedules (_ hiddenID: Int) -> Int {
        if let result = self.sortedschedules?.filter({return (($0.value(forKey: "hiddenID") as? Int)! == hiddenID
            && ($0.value(forKey: "start") as? Date)!.timeIntervalSinceNow > 0 )}) {
            return result.count
        } else {
            return 0
        }
    }

    /// Function is reading Schedule plans and transform plans to
    /// array of NSDictionary.
    /// - returns : none
    private func createScheduleAsNSDictionary () {
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

    // Number of seconds ahead of time to read
    // scheduled jobs

    // Start timer or not in either main start window
    // Or in main execute window
    // seconds > 0 and <= 1800 every 1 second ( 0 - 30 minutes )
    // seconds > 1800 and <= 2 hours x 3600 <= 7200 every 60 seconds (minute) ( 30 minutes - 2 hours)
    // seconds > 7200 and <= 6 hours x 3600 = 21600 every 300 seconds (5 minues) ( 2 hours - 6 hours )
    // seconds > 21600 <= 24 x 3600 = 86,400 every 1/2 hour = 1800 seconds (30 minutes) ( 6 hours - 24 hours)
    func startTimerseconds () -> Double {
        if let start = self.jobToExecute() {
            let dateStart: Date = (start.value(forKey: "start") as? Date)!
            let seconds = Tools().timeDoubleSeconds(dateStart, enddate: nil)
            // 30 minutes every second
            if seconds > 0 && seconds <= 1800 {
                // Update every second
                return 1
                // 30 minutes and 2 hours every minute
            } else if seconds > 1800 && seconds <= 7200 {
                return 60
                // 2 and 6 hours every 5 minutes
            } else if seconds > 7200 && seconds <= 21600 {
                return 300
                // 7 and 24 hours every 30 minutes
            } else if seconds <= 86400 {
                // Dont start
                return 1800
            } else {
                // Dont start
                return 0
            }
        } else {
            if self.scheduleInProgress {
                return 1
            } else {
                return 0
            }
        }
    }

    // Info about next remote servers and paths for scheduled backup.
    func remoteServerAndPathNextTwoTasks() -> Array<String> {
        var dict1: NSDictionary?
        var dict2: NSDictionary?
        var array = Array<String>()
        guard self.sortedschedules != nil else { return [""] }
        if (self.sortedschedules!.count) > 1 {
            dict1 = self.sortedschedules![0]
            dict2 = self.sortedschedules![1]
        } else {
            if (self.sortedschedules!.count) > 0 {
                dict1 = self.sortedschedules![0]
            }
        }
        if dict1 != nil {
            let hiddenID1 = dict1!.value(forKey: "hiddenID") as? Int
            array.append(self.configurationsNoS!.getResourceConfiguration(hiddenID1!, resource: .offsiteServer))
            array.append(self.configurationsNoS!.getResourceConfiguration(hiddenID1!, resource: .localCatalog))
        }
        if dict2 != nil {
            let hiddenID2 = dict2?.value(forKey: "hiddenID") as? Int
            array.append(self.configurationsNoS!.getResourceConfiguration(hiddenID2!, resource: .offsiteServer))
            array.append(self.configurationsNoS!.getResourceConfiguration(hiddenID2!, resource: .localCatalog))
        }
        // Return either 0, 2 or 4 elements
        return array
    }

    // Info on first screen - two first scheduled backups.
    func whenIsNextTwoTasksString() -> Array<String> {
        var firstbackup: String?
        var secondbackup: String?
        guard self.sortedschedules != nil else {
            return [" ... none ...", " ... none ..."]
        }
        // We are calculating the first object
        if (self.sortedschedules!.count) > 0 {
            if (self.sortedschedules!.count) > 0 {
                if let minutes1 = self.sortedschedules?[0] {
                    let date1: Date = (minutes1.value(forKey: "start") as? Date)!
                    firstbackup = Tools().timeString(date1, enddate: nil)
                }
            } else {
                firstbackup = " ... none ..."
                secondbackup = " ... none ..."
            }
            if (self.sortedschedules!.count) > 1 {
                if let minutes2 = self.sortedschedules?[1] {
                    let date2: Date = (minutes2.value(forKey: "start") as? Date)!
                    secondbackup = Tools().timeString(date2, enddate: nil)
                }
            } else {
                secondbackup = " ... none ..."
            }
        } else {
            firstbackup = " ... none ..."
            secondbackup = " ... none ..."
        }
        return [firstbackup!, secondbackup!]
    }

    // Returns when to next tasks ar due in seconds
    func whenIsNextTwoTasksDouble() -> Array<Double> {
        var firstbackup: Double?
        var secondbackup: Double?
        // We are calculating the first object
        guard self.sortedschedules != nil else { return [-1, -1] }
        guard self.sortedschedules!.count > 0 else { return [-1, -1] }
        if (self.sortedschedules!.count) > 0 {
            if let minutes1 = self.sortedschedules?[0] {
                let date1: Date = (minutes1.value(forKey: "start") as? Date)!
                firstbackup = Tools().timeDoubleMinutes(date1, enddate: nil)
            }
        } else {
            firstbackup = -1
            secondbackup = -1
        }
        if (self.sortedschedules!.count) > 1 {
            if let minutes2 = self.sortedschedules?[1] {
                let date2: Date = (minutes2.value(forKey: "start") as? Date)!
                secondbackup = Tools().timeDoubleMinutes(date2, enddate: nil)
            }
        } else {
            secondbackup = -1
        }
        return [firstbackup!, secondbackup!]
    }

    init () {
        // configurationsNoS
        self.configurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
            as? ViewControllertabMain
        self.schedulesDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
            as? ViewControllertabMain
        self.configurationsNoS = self.configurationsDelegate?.getconfigurationsobject()
        self.schedulesNoS = self.schedulesDelegate?.getschedulesobject()
        // configurationsNoS
        // Getting the Schedule and expanding all the jobs
        self.scheduleConfiguration = self.schedulesNoS!.getSchedule()
        self.createScheduleAsNSDictionary()
        self.sortAndExpandScheduleData()
    }
}

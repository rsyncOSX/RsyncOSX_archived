//
//  ScheduleSortedAndExpanded.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

class ScheduleSortedAndExpand {

    // DATA STRUCTURES

    // Array to store all scheduled jobs and history of executions
    // Will be kept in memory until destroyed
    private var scheduleAsNSDictionary: Array<NSDictionary>?
    private var scheduleAsConfiguration: Array<ConfigurationSchedule>?
    // Sorting and expanding Schedule data.
    // Private func called from getScheduledTasks()
    private var sortedAndExpandedScheduleData: Array<NSDictionary>?
    // Schedule in progress
    private var scheduleInProgress: Bool = false

    // First job to execute.Job is first element in 
    // self.sortedAndExpandedScheduleData
    func jobToExecute() -> NSDictionary? {

        guard self.sortedAndExpandedScheduleData != nil else {
            return nil
        }
        guard self.sortedAndExpandedScheduleData!.count > 0 else {
            return nil
        }
        return self.sortedAndExpandedScheduleData![0]
    }

    // Returns reference to all sorted and expanded schedules
    func getsortedAndExpandedScheduleData() -> Array<NSDictionary>? {
        return self.sortedAndExpandedScheduleData
    }

    // True if scheduled process is about to start
    func getScheduledOperationInProgress() -> Bool {
        // Calculate next schedule in progress
        if (self.whenIsNextTwoTasksDouble()[0] > 0 &&
            self.whenIsNextTwoTasksDouble()[0] < SharingManagerConfiguration.sharedInstance.scheduledTaskdisableExecute) {
            // Value 0 disables the function
            if (SharingManagerConfiguration.sharedInstance.scheduledTaskdisableExecute > 0) {
                self.scheduleInProgress = true
            } else {
                self.scheduleInProgress = false
            }
        } else {
            self.scheduleInProgress = false
        }
        return self.scheduleInProgress
    }

    // Expanding and sorting Scheduledata
    private func sortAndExpandScheduleData() {

        var expandedData = Array<NSDictionary>()
        let dateformatter = Utils.sharedInstance.setDateformat()

        for i in 0 ..< self.scheduleAsNSDictionary!.count {

            let dict = self.scheduleAsNSDictionary![i]
            let dateStop: Date = dateformatter.date(from: (dict.value(forKey: "dateStop") as? String)!)!
            let dateStart: Date = dateformatter.date(from: (dict.value(forKey: "dateStart") as? String)!)!

            let days: Double = dateStop.timeIntervalSinceNow/(60*60*24)
            let schedule: String = (dict.value(forKey: "schedule") as? String)!
            let seconds: Double = dateStop.timeIntervalSinceNow

            // Get all jobs which are not executed

            if (seconds > 0) {

                switch schedule {
                case "once" :
                    let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
                    let dict: NSDictionary = [
                        "start": dateStop,
                        "hiddenID": hiddenID,
                        "dateStart": dateStart,
                        "schedule": schedule]
                    expandedData.append(dict)
                case "daily":
                    var k = Int(days)
                    if ( k < 370) {
                        if k > 30 {
                            k = 30
                        }
                        for j in 0 ..< k {
                            var dateComponent = DateComponents()
                            dateComponent.day = j+1
                            let cal = Calendar.current
                            if let start: Date = cal.date(byAdding: dateComponent, to: dateStart) {
                                if (start.timeIntervalSinceNow > 0) {
                                    let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
                                    let dict: NSDictionary = [
                                        "start": start,
                                        "hiddenID": hiddenID,
                                        "dateStart": dateStart,
                                        "schedule": schedule]
                                    expandedData.append(dict)
                                }
                            }
                        }
                    }
                case "weekly":
                    var k = Int(days)
                    if (k < 370) {
                        if (k > 30) {
                            k = 30
                        }
                        for j in 0 ..< Int(k/7) {
                            var dateComponent = DateComponents()
                            dateComponent.day = ((j+1)*7)
                            let cal = Calendar.current
                            if let start: Date = cal.date(byAdding: dateComponent, to: dateStart) {
                                if (start.timeIntervalSinceNow > 0) {
                                    let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
                                    let dict: NSDictionary = [
                                        "start": start,
                                        "hiddenID": hiddenID,
                                        "dateStart": dateStart,
                                        "schedule": schedule]
                                    expandedData.append(dict)
                                }
                            }
                        }
                    }
                default:
                    break
                }
            }

        let sorted: [NSDictionary] = expandedData.sorted { (dict1, dict2) -> Bool in
            if (dict1.value(forKey: "start") as? Date)!.timeIntervalSince((dict2.value(forKey: "start") as? Date)!) > 0 {
                return false
            } else {
                return true
            }
        }
        self.sortedAndExpandedScheduleData = sorted
        // Set reference to the first scheduled job
        SharingManagerSchedule.sharedInstance.scheduledJob = self.jobToExecute()
        }
    }

    // Calculates number of future Schedules ID by hiddenID
    func numberOfFutureSchedules (_ hiddenID: Int) -> Int {
        if let result = self.sortedAndExpandedScheduleData?.filter({return (($0.value(forKey: "hiddenID") as? Int)! == hiddenID
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
        guard self.scheduleAsConfiguration != nil else {
            return
        }
        var data = Array<NSDictionary>()
        for i in 0 ..< self.scheduleAsConfiguration!.count {
            if self.scheduleAsConfiguration![i].dateStop != nil {
                if (self.scheduleAsConfiguration![i].schedule != "stopped") {
                    let dict: NSDictionary = [
                        "dateStart": self.scheduleAsConfiguration![i].dateStart,
                        "dateStop": self.scheduleAsConfiguration![i].dateStop!,
                        "hiddenID": self.scheduleAsConfiguration![i].hiddenID,
                        "schedule": self.scheduleAsConfiguration![i].schedule
                    ]
                    data.append(dict as NSDictionary)
                }
            }
        }
        self.scheduleAsNSDictionary = data
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
            let seconds = self.timeDoubleSeconds(dateStart, enddate: nil)

            // 30 minutes every second
            if (seconds > 0 && seconds <= 1800) {
                // Update every second
                return 1
                // 30 minutes and 2 hours every minute
            } else if (seconds > 1800 && seconds <= 7200) {
                return 60
                // 2 and 6 hours every 5 minutes
            } else if (seconds > 7200 && seconds <= 21600) {
                return 300
                // 7 and 24 hours every 30 minutes
            } else if (seconds <= 86400 ) {
                // Dont start
                return 1800
            } else {
                // Dont start
                return 0
            }
        } else {
            if (self.scheduleInProgress) {
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

        guard self.sortedAndExpandedScheduleData != nil else {
            return [""]
        }

        if (self.sortedAndExpandedScheduleData!.count) > 1 {
            dict1 = self.sortedAndExpandedScheduleData![0]
            dict2 = self.sortedAndExpandedScheduleData![1]
        } else {
            if (self.sortedAndExpandedScheduleData!.count) > 0 {
                dict1 = self.sortedAndExpandedScheduleData![0]
            }
        }
        if (dict1 != nil) {
            let hiddenID1 = dict1!.value(forKey: "hiddenID") as? Int
            array.append(SharingManagerConfiguration.sharedInstance.getResourceConfiguration(hiddenID1!, resource: .offsiteServer))
            array.append(SharingManagerConfiguration.sharedInstance.getResourceConfiguration(hiddenID1!, resource: .localCatalog))
        }
        if (dict2 != nil) {
            let hiddenID2 = dict2?.value(forKey: "hiddenID") as? Int
            array.append(SharingManagerConfiguration.sharedInstance.getResourceConfiguration(hiddenID2!, resource: .offsiteServer))
            array.append(SharingManagerConfiguration.sharedInstance.getResourceConfiguration(hiddenID2!, resource: .localCatalog))
        }
        // Return either 0, 2 or 4 elements
        return array
    }

    // Info on first screen - two first scheduled backups.
    func whenIsNextTwoTasksString() -> Array<String> {

        var firstbackup: String?
        var secondbackup: String?

        guard self.sortedAndExpandedScheduleData != nil else {
            return [" ... none ...", " ... none ..."]
        }

        // We are calculating the first object
        if (self.sortedAndExpandedScheduleData!.count) > 0 {
            if (self.sortedAndExpandedScheduleData!.count) > 0 {
                if let minutes1 = self.sortedAndExpandedScheduleData?[0] {
                    let date1: Date = (minutes1.value(forKey: "start") as? Date)!
                    firstbackup = self.timeString(date1, enddate: nil)
                }
            } else {
                firstbackup = " ... none ..."
                secondbackup = " ... none ..."
            }
            if (self.sortedAndExpandedScheduleData!.count) > 1 {
                if let minutes2 = self.sortedAndExpandedScheduleData?[1] {
                    let date2: Date = (minutes2.value(forKey: "start") as? Date)!
                    secondbackup = self.timeString(date2, enddate: nil)
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

        guard self.sortedAndExpandedScheduleData != nil else {
            return [-1, -1]
        }
        guard self.sortedAndExpandedScheduleData!.count > 0 else {
            return [-1, -1]
        }
        if (self.sortedAndExpandedScheduleData!.count) > 0 {
            if let minutes1 = self.sortedAndExpandedScheduleData?[0] {
                let date1: Date = (minutes1.value(forKey: "start") as? Date)!
                firstbackup = self.timeDoubleMinutes(date1, enddate: nil)
            }
        } else {
            firstbackup = -1
            secondbackup = -1
        }
        if (self.sortedAndExpandedScheduleData!.count) > 1 {
            if let minutes2 = self.sortedAndExpandedScheduleData?[1] {
                let date2: Date = (minutes2.value(forKey: "start") as? Date)!
                secondbackup = self.timeDoubleMinutes(date2, enddate: nil)
            }
        } else {
            secondbackup = -1
        }
        return [firstbackup!, secondbackup!]
    }

    // Calculate seconds from now to startdate
    private func seconds (_ startdate: Date, enddate: Date?) -> Double {
        if (enddate == nil) {
            return startdate.timeIntervalSinceNow
        } else {
            return enddate!.timeIntervalSince(startdate)
        }
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    // Returns time in minutes
    func timeDoubleMinutes (_ startdate: Date, enddate: Date?) -> Double {
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        let (_, minf) = modf (seconds / 3600)
        let (min, _) = modf (60 * minf)
        return min
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    // Returns time in seconds
    func timeDoubleSeconds (_ startdate: Date, enddate: Date?) -> Double {
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        return seconds
    }

    // Returns number of hours between start and stop date
    func timehourInt(_ startdate: Date, enddate: Date?) -> Int {
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        let (hr, _) = modf (seconds / 3600)
        return Int(hr)
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    func timeString (_ startdate: Date, enddate: Date?) -> String {
        var result: String?
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        let (hr, minf) = modf (seconds / 3600)
        let (min, secf) = modf (60 * minf)
        // hr, min, 60 * secf
        if (hr == 0 && min == 0) {
            result = String(format:"%.0f", 60 * secf) + " seconds"
        } else if ( hr == 0 && min < 60) {
            result = String(format:"%.0f", min) + " minutes " + String(format:"%.0f", 60 * secf) + " seconds"
        } else if (hr < 25 ) {
            result = String(format:"%.0f", hr) + " hours " + String(format:"%.0f", min) + " minutes"
        } else {
            result = String(format:"%.0f", hr/24) + " days"
        }
        if (secf <= 0) {
            result = " ... working ... "
        }
        return result!
    }

    init () {
        // Getting the Schedule and expanding all the jobs
        self.scheduleAsConfiguration = SharingManagerSchedule.sharedInstance.getSchedule()
        self.createScheduleAsNSDictionary()
        self.sortAndExpandScheduleData()
    }
}

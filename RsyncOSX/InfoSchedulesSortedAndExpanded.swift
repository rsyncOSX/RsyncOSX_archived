//
//  InfrScheduleSortedAndExpanded.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 22/09/2017.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//  swiftlint More work to fix - 17 July 2017
//
//  swiftlint:disable syntactic_sugar

import Foundation
import Cocoa

class InfoScheduleSortedAndExpand: SetConfigurations {

    // Reference to main View
    private var sortedschedules: Array<NSDictionary>?
    private var scheduleInProgress: Bool = false

    // First job to execute.Job is first element in
    private func jobToExecute() -> NSDictionary? {
        guard self.sortedschedules != nil else { return nil}
        guard self.sortedschedules!.count > 0 else {return nil}
        return self.sortedschedules![0]
    }

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
            if self.scheduleInProgress { return 1 } else { return 0 }
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
            array.append(self.configurations!.getResourceConfiguration(hiddenID1!, resource: .offsiteServer))
            array.append(self.configurations!.getResourceConfiguration(hiddenID1!, resource: .localCatalog))
        }
        if dict2 != nil {
            let hiddenID2 = dict2?.value(forKey: "hiddenID") as? Int
            array.append(self.configurations!.getResourceConfiguration(hiddenID2!, resource: .offsiteServer))
            array.append(self.configurations!.getResourceConfiguration(hiddenID2!, resource: .localCatalog))
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

    init (sortedandexpanded: ScheduleSortedAndExpand?) {
        guard sortedandexpanded != nil else { return }
        self.sortedschedules = sortedandexpanded!.getsortedAndExpandedScheduleData()
    }
}

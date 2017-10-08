//
//  ScheduleWriteLoggData.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 19.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable syntactic_sugar line_length

import Foundation
import Cocoa

class ScheduleWriteLoggData {

    weak var configurationsDelegate: GetConfigurationsObject?
    var configurations: Configurations?
    var storageapi: PersistentStorageAPI?
    var schedules: Array<ConfigurationSchedule>?
    weak var refreshlogviewDelegate: Reloadandrefresh?
    weak var deselectrowDelegate: DeselectRowTable?

    func deletelogrow(hiddenID: Int, parent: Int, sibling: Int) {
        guard parent < self.schedules!.count else {
            return
        }
        guard sibling <  self.schedules![parent].logrecords.count else {
            return
        }
        self.schedules![parent].logrecords.remove(at: sibling)
        self.storageapi!.saveScheduleFromMemory()
        self.refreshlogviewDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
        self.refreshlogviewDelegate?.reloadtabledata()
    }

    /// Function adds results of task to file (via memory). Memory are
    /// saved after changed. Used in either single tasks or batch.
    /// - parameter hiddenID : hiddenID for task
    /// - parameter result : String representation of result
    /// - parameter date : String representation of date and time stamp
    func addlogtaskmanuel(_ hiddenID: Int, result: String) {
        // Set the current date
        let currendate = Date()
        let dateformatter = Tools().setDateformat()
        let date = dateformatter.string(from: currendate)
        var inserted: Bool = self.addloggtaskmanualexisting(hiddenID, result: result, date: date)
        // Record does not exist, create new Schedule (not inserted)
        if inserted == false {
            inserted = self.addloggtaskmanulnew(hiddenID, result: result, date: date)
        }
        if inserted {
            self.storageapi!.saveScheduleFromMemory()
            self.deselectrowDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
            self.deselectrowDelegate?.deselectRow()
        }
    }

    private func addloggtaskmanualexisting(_ hiddenID: Int, result: String, date: String) -> Bool {
        var loggadded: Bool = false
        for i in 0 ..< self.schedules!.count where
            self.configurations!.getResourceConfiguration(hiddenID, resource: .task) == "backup" {
                if self.schedules![i].hiddenID == hiddenID  &&
                    self.schedules![i].schedule == "manuel" &&
                    self.schedules![i].dateStop == nil {
                    let dict = NSMutableDictionary()
                    dict.setObject(date, forKey: "dateExecuted" as NSCopying)
                    dict.setObject(result, forKey: "resultExecuted" as NSCopying)
                    self.schedules![i].logrecords.append(dict)
                    loggadded = true
                }
            }
        return loggadded
    }

    private func addloggtaskmanulnew(_ hiddenID: Int, result: String, date: String) -> Bool {
        var loggadded: Bool = false
        if (self.configurations!.getResourceConfiguration(hiddenID, resource: .task) == "backup") {
            let masterdict = NSMutableDictionary()
            masterdict.setObject(hiddenID, forKey: "hiddenID" as NSCopying)
            masterdict.setObject("01 Jan 1900 00:00", forKey: "dateStart" as NSCopying)
            masterdict.setObject("manuel", forKey: "schedule" as NSCopying)
            let dict = NSMutableDictionary()
            dict.setObject(date, forKey: "dateExecuted" as NSCopying)
            dict.setObject(result, forKey: "resultExecuted" as NSCopying)
            let executed = NSMutableArray()
            executed.add(dict)
            let newSchedule = ConfigurationSchedule(dictionary: masterdict, log: executed)
            self.schedules!.append(newSchedule)
            loggadded = true
        }
        return loggadded
    }

    /// Function adds results of task to file (via memory). Memory are
    /// saved after changed. Used in either single tasks or batch.
    /// - parameter hiddenID : hiddenID for task
    /// - parameter dateStart : String representation of date and time stamp start schedule
    /// - parameter result : String representation of result
    /// - parameter date : String representation of date and time stamp for task executed
    /// - parameter schedule : schedule of task
    func addresultschedule(_ hiddenID: Int, dateStart: String, result: String, date: String, schedule: String) {
        if self.configurations!.detailedlogging {
            loop : for i in 0 ..< self.schedules!.count {
                if self.schedules![i].hiddenID == hiddenID  &&
                    self.schedules![i].schedule == schedule &&
                    self.schedules![i].dateStart == dateStart {
                    if (self.configurations!.getResourceConfiguration(hiddenID, resource: .task) == "backup") {
                        let dict = NSMutableDictionary()
                        dict.setObject(date, forKey: "dateExecuted" as NSCopying)
                        dict.setObject(result, forKey: "resultExecuted" as NSCopying)
                        self.schedules![i].logrecords.append(dict)
                        self.storageapi!.saveScheduleFromMemory()
                        break loop
                    }
                }
            }
        }
    }

    init(viewcontroller: NSViewController) {
        self.configurationsDelegate = viewcontroller as? ViewControllertabMain
        self.configurations = self.configurationsDelegate?.getconfigurationsobject()
        self.schedules = Array<ConfigurationSchedule>()
    }
}

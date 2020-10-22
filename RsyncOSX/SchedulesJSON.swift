//
//  SchedulesJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable trailing_comma

import Foundation

class SchedulesJSON: Schedules {
    // Function adds results of task to file (via memory). Memory are
    // saved after changed. Used in single tasks
    // - parameter hiddenID : hiddenID for task
    // - parameter result : String representation of result
    // - parameter date : String representation of date and time stamp
    override func addlogpermanentstore(hiddenID: Int, result: String) {
        if ViewControllerReference.shared.detailedlogging {
            // Set the current date
            let currendate = Date()
            let date = currendate.en_us_string_from_date()
            if let config = self.getconfig(hiddenID: hiddenID) {
                var resultannotaded: String?
                if config.task == ViewControllerReference.shared.snapshot {
                    let snapshotnum = String(config.snapshotnum!)
                    resultannotaded = "(" + snapshotnum + ") " + result
                } else {
                    resultannotaded = result
                }
                var inserted: Bool = self.addlogexisting(hiddenID: hiddenID, result: resultannotaded ?? "", date: date)
                // Record does not exist, create new Schedule (not inserted)
                if inserted == false {
                    inserted = self.addlognew(hiddenID: hiddenID, result: resultannotaded ?? "", date: date)
                }
                if inserted {
                    PersistentStorageSchedulingJSON(profile: self.profile).savescheduleInMemoryToPersistentStore()
                    self.deselectrowtable(vcontroller: .vctabmain)
                }
            }
        }
    }

    // Function adds new Shcedules (plans). Functions writes
    // schedule plans to permanent store.
    // - parameter hiddenID: hiddenID for task
    // - parameter schedule: schedule
    // - parameter start: start date and time
    // - parameter stop: stop date and time
    override func addschedule(hiddenID: Int, schedule: Scheduletype, start: Date) {
        var stop: Date?
        if schedule == .once {
            stop = start
        } else {
            stop = "01 Jan 2100 00:00".en_us_date_from_string()
        }
        let dict = NSMutableDictionary()
        let offsiteserver = self.configurations?.getResourceConfiguration(hiddenID, resource: .offsiteServer)
        dict.setObject(hiddenID, forKey: "hiddenID" as NSCopying)
        dict.setObject(start.en_us_string_from_date(), forKey: "dateStart" as NSCopying)
        dict.setObject(stop!.en_us_string_from_date(), forKey: "dateStop" as NSCopying)
        dict.setObject(offsiteserver as Any, forKey: "offsiteserver" as NSCopying)
        switch schedule {
        case .once:
            dict.setObject(Scheduletype.once.rawValue, forKey: "schedule" as NSCopying)
        case .daily:
            dict.setObject(Scheduletype.daily.rawValue, forKey: "schedule" as NSCopying)
        case .weekly:
            dict.setObject(Scheduletype.weekly.rawValue, forKey: "schedule" as NSCopying)
        default:
            return
        }
        let newSchedule = ConfigurationSchedule(dictionary: dict, log: nil, nolog: true)
        self.schedules?.append(newSchedule)
        PersistentStorageSchedulingJSON(profile: self.profile).savescheduleInMemoryToPersistentStore()
        self.reloadtable(vcontroller: .vctabschedule)
    }

    // Function deletes all Schedules by hiddenID. Invoked when Configurations are
    // deleted. When a Configuration are deleted all tasks connected to
    // Configuration has to  be deleted.
    // - parameter hiddenID : hiddenID for task
    override func deletescheduleonetask(hiddenID: Int) {
        var delete: Bool = false
        for i in 0 ..< (self.schedules?.count ?? 0) where self.schedules?[i].hiddenID == hiddenID {
            // Mark Schedules for delete
            // Cannot delete in memory, index out of bound is result
            self.schedules?[i].delete = true
            delete = true
        }
        if delete {
            PersistentStorageSchedulingJSON(profile: self.profile).savescheduleInMemoryToPersistentStore()
            // Send message about refresh tableView
            self.reloadtable(vcontroller: .vctabmain)
        }
    }

    // Function either deletes or stops Schedules.
    // - parameter data : array of Schedules which some of them are either marked for stop or delete
    override func deleteandstopschedules(data: [NSMutableDictionary]?) {
        var update: Bool = false
        if (data?.count ?? 0) > 0 {
            if let stop = data?.filter({ (($0.value(forKey: "stopCellID") as? Int) == 1) }) {
                // Stop Schedules
                if stop.count > 0 {
                    update = true
                    for i in 0 ..< stop.count {
                        self.stop(dict: stop[i])
                    }
                }
            }
            if let delete = data?.filter({ (($0.value(forKey: "deleteCellID") as? Int) == 1) }) {
                if delete.count > 0 {
                    update = true
                    for i in 0 ..< delete.count {
                        self.delete(dict: delete[i])
                    }
                }
            }
            if update {
                // Saving the resulting data file
                PersistentStorageSchedulingJSON(profile: self.profile).savescheduleInMemoryToPersistentStore()
                // Send message about refresh tableView
                self.reloadtable(vcontroller: .vctabmain)
                self.reloadtable(vcontroller: .vctabschedule)
            }
        }
    }

    // Function for reading all jobs for schedule and all history of past executions.
    // Schedules are stored in self.schedules. Schedules are sorted after hiddenID.
    override func readschedules() {
        // var store = PersistentStorageScheduling(profile: self.profile).getScheduleandhistory(nolog: false)
        // guard store != nil else { return }
        let store = ReadWriteSchedulesJSON(profile: self.profile).decodedjson
        var data = [ConfigurationSchedule]()
        for i in 0 ..< (store?.count ?? 0) {
            if let scheduleitem = (store?[i] as? DecodeScheduleJSON) {
                var transformed = transform(object: scheduleitem)
                transformed.profilename = self.profile
                data.append(transformed)
            }
        }
        // Sorting schedule after hiddenID
        data.sort { (schedule1, schedule2) -> Bool in
            if schedule1.hiddenID > schedule2.hiddenID {
                return false
            } else {
                return true
            }
        }
        // Setting self.Schedule as data
        self.schedules = data
    }
}

extension Schedules {
    func transform(object: DecodeScheduleJSON) -> ConfigurationSchedule {
        var log: [Any]?
        let dict: NSMutableDictionary = [
            "hiddenID": object.hiddenID ?? -1,
            "offsiteserver": object.offsiteserver ?? "",
            "dateStart": object.dateStart ?? "",
            "schedule": object.schedule ?? "",
            "profilename": object.profilename ?? "",
        ]
        if object.dateStop?.isEmpty == false {
            dict.setObject(object.dateStop ?? "", forKey: "dateStop" as NSCopying)
        }
        for i in 0 ..< (object.logrecords?.count ?? 0) {
            if i == 0 { log = Array() }
            let logdict: NSMutableDictionary = [
                "dateExecuted": object.logrecords![i].dateExecuted ?? "",
                "resultExecuted": object.logrecords![i].resultExecuted ?? "",
            ]
            log?.append(logdict)
        }
        return ConfigurationSchedule(dictionary: dict as NSDictionary, log: log as NSArray?, nolog: false)
    }
}

//
//  This object stays in memory runtime and holds key data and operations on Schedules.
//  The obect is the model for the Schedules but also acts as Controller when
//  the ViewControllers reads or updates data.
//
//  Created by Thomas Evensen on 09/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable trailing_comma

import Cocoa
import Foundation

class Schedules: ScheduleWriteLoggData {
    // Return reference to Schedule data
    // self.Schedule is privat data
    func getSchedule() -> [ConfigurationSchedule] {
        return self.schedules ?? []
    }

    // Function adds new Shcedules (plans). Functions writes
    // schedule plans to permanent store.
    // - parameter hiddenID: hiddenID for task
    // - parameter schedule: schedule
    // - parameter start: start date and time
    // - parameter stop: stop date and time
    func addschedule(hiddenID: Int, schedule: Scheduletype, start: Date) {
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
        self.schedules!.append(newSchedule)
        _ = PersistentStorageScheduling(profile: self.profile).savescheduleInMemoryToPersistentStore()
        self.reloadtable(vcontroller: .vctabschedule)
    }

    // Function deletes all Schedules by hiddenID. Invoked when Configurations are
    // deleted. When a Configuration are deleted all tasks connected to
    // Configuration has to  be deleted.
    // - parameter hiddenID : hiddenID for task
    func deletescheduleonetask(hiddenID: Int) {
        var delete: Bool = false
        for i in 0 ..< (self.schedules?.count ?? 0) where self.schedules![i].hiddenID == hiddenID {
            // Mark Schedules for delete
            // Cannot delete in memory, index out of bound is result
            self.schedules![i].delete = true
            delete = true
        }
        if delete {
            _ = PersistentStorageScheduling(profile: self.profile).savescheduleInMemoryToPersistentStore()
            // Send message about refresh tableView
            self.reloadtable(vcontroller: .vctabmain)
        }
    }

    // Function reads all Schedule data for one task by hiddenID
    // - parameter hiddenID : hiddenID for task
    // - returns : array of Schedules sorted after startDate
    func readscheduleonetask(hiddenID: Int?) -> [NSMutableDictionary]? {
        guard hiddenID != nil else { return nil }
        var row: NSMutableDictionary
        var data = [NSMutableDictionary]()
        for i in 0 ..< (self.schedules?.count ?? 0) {
            if self.schedules![i].hiddenID == hiddenID {
                row = [
                    "dateStart": self.schedules![i].dateStart,
                    "dayinweek": self.schedules![i].dateStart.en_us_date_from_string().dayNameShort(),
                    "stopCellID": 0,
                    "deleteCellID": 0,
                    "dateStop": "",
                    "schedule": self.schedules![i].schedule,
                    "hiddenID": schedules![i].hiddenID,
                    "numberoflogs": String(schedules![i].logrecords.count),
                ]
                if self.schedules![i].dateStop == nil {
                    row.setValue("no stop date", forKey: "dateStop")
                } else {
                    row.setValue(self.schedules![i].dateStop, forKey: "dateStop")
                }
                if self.schedules![i].schedule == Scheduletype.stopped.rawValue {
                    row.setValue(1, forKey: "stopCellID")
                }
                data.append(row)
            }
            // Sorting schedule after dateStart, last startdate on top
            data.sort { (sched1, sched2) -> Bool in
                if (sched1.value(forKey: "dateStart") as? String)!.en_us_date_from_string() >
                    (sched2.value(forKey: "dateStart") as? String)!.en_us_date_from_string() {
                    return true
                } else {
                    return false
                }
            }
        }
        return data
    }

    // Function either deletes or stops Schedules.
    // - parameter data : array of Schedules which some of them are either marked for stop or delete
    func deleteandstopschedules(data: [NSMutableDictionary]?) {
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
                _ = PersistentStorageScheduling(profile: self.profile).savescheduleInMemoryToPersistentStore()
                // Send message about refresh tableView
                self.reloadtable(vcontroller: .vctabmain)
                self.reloadtable(vcontroller: .vctabschedule)
            }
        }
    }

    // Test if Schedule record in memory is set to delete or not
    func delete(dict: NSDictionary) {
        if let hiddenID = dict.value(forKey: "hiddenID") as? Int {
            if let schedule = dict.value(forKey: "schedule") as? String {
                if let datestart = dict.value(forKey: "dateStart") as? String {
                    if let i = self.schedules?.firstIndex(where: { $0.hiddenID == hiddenID
                            && $0.schedule == schedule
                            && $0.dateStart == datestart
                    }) {
                        self.schedules![i].delete = true
                    }
                }
            }
        }
    }

    // Test if Schedule record in memory is set to stop er not
    func stop(dict: NSDictionary) {
        if let hiddenID = dict.value(forKey: "hiddenID") as? Int {
            if let schedule = dict.value(forKey: "schedule") as? String {
                if let datestart = dict.value(forKey: "dateStart") as? String {
                    if let i = self.schedules?.firstIndex(where: { $0.hiddenID == hiddenID
                            && $0.schedule == schedule
                            && $0.dateStart == datestart
                    }) {
                        self.schedules![i].schedule = Scheduletype.stopped.rawValue
                        self.schedules![i].dateStop = Date().en_us_string_from_date()
                    }
                }
            }
        }
    }

    // Function for reading all jobs for schedule and all history of past executions.
    // Schedules are stored in self.schedules. Schedules are sorted after hiddenID.
    private func readschedules() {
        var store = PersistentStorageScheduling(profile: self.profile).getScheduleandhistory(nolog: false)
        guard store != nil else { return }
        var data = [ConfigurationSchedule]()
        for i in 0 ..< (store?.count ?? 0) where store?[i].logrecords.isEmpty == false || store?[i].dateStop != nil {
            store?[i].profilename = self.profile
            data.append(store![i])
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

    override init(profile: String?) {
        super.init(profile: profile)
        self.profile = profile
        self.readschedules()
        if ViewControllerReference.shared.checkinput {
            self.schedules = Reorgschedule().mergerecords(data: self.schedules)
        }
    }
}

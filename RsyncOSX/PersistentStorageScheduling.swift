//
//  PersistenStorescheduling.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//   Interface between Schedule in memory and
//   presistent store. Class is a interface
//   for Schedule.
//
//   swiftlint:disable syntactic_sugar

import Foundation

protocol Readupdatedschedules: class {
    func readAllSchedules()
}

final class PersistentStorageScheduling: Readwritefiles {

    weak var readschedulesDelegate: Readupdatedschedules?
    // Variables holds all scheduledata
    private var schedules: [NSDictionary]?

    /// Function reads schedules from permanent store
    /// - returns : array of NSDictonarys, return might be nil if schedule is already in memory
    func readSchedulesFromPermanentStore() -> [NSDictionary]? {
        return self.schedules
    }

    // Saving Schedules from MEMORY to persistent store
    func savescheduleInMemoryToPersistentStore() {
        var array = Array<NSDictionary>()
        // Reading Schedules from memory
        let data = Schedules.shared.getSchedule()
        for i in 0 ..< data.count {
            let schedule = data[i]
            let dict: NSMutableDictionary = [
                "hiddenID": schedule.hiddenID,
                "dateStart": schedule.dateStart,
                "schedule": schedule.schedule,
                "executed": schedule.logrecords]
            if schedule.dateStop != nil {
                dict.setValue(schedule.dateStop, forKey: "dateStop")
            }
            if let delete = schedule.delete {
                if !delete {
                    array.append(dict)
                }
            } else {
                array.append(dict)
            }
        }
        // Write array to persistent store
        self.writeToStore(array)
    }

    // Saving not deleted schedule records to persistent store
    // Deleted Schedule by hiddenID
    func savescheduleDeletedRecordsToFile (_ hiddenID: Int) {
        var array = Array<NSDictionary>()
        let Schedule = Schedules.shared.getSchedule()
        for i in 0 ..< Schedule.count {
            let schedule = Schedule[i]
            if schedule.delete == nil && schedule.hiddenID != hiddenID {
                let dict: NSMutableDictionary = [
                    "hiddenID": schedule.hiddenID,
                    "dateStart": schedule.dateStart,
                    "schedule": schedule.schedule,
                    "executed": schedule.logrecords]
                if schedule.dateStop != nil {
                    dict.setValue(schedule.dateStop, forKey: "dateStop")
                }
                array.append(dict)
            }
        }
        // Write array to persistent store
        self.writeToStore(array)
    }

    // Writing schedules to persistent store
    // Schedule is Array<NSDictionary>
    private func writeToStore (_ array: Array<NSDictionary>) {
        if (self.writeDatatoPersistentStorage(array, task: .schedule)) {
            Schedules.shared.readAllSchedules()
        }
    }

    init (profile: String?) {
        // Create the readwritefiles object
        super.init(task: .schedule, profile: profile)
        // Reading Configurations from memory or disk, if dirty read from disk
        // if not dirty set self.configurationFromStore to nil to tell
        // anyone to read Configurations from memory
        if let schedulesFromPersistentstore = self.getDatafromfile() {
            self.schedules = schedulesFromPersistentstore
        } else {
            self.schedules = nil
        }
    }
}

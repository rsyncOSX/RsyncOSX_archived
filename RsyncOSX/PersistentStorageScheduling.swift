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
//   swiftlint:disable syntactic_sugar line_length

import Foundation

final class PersistentStorageScheduling: Readwritefiles, SetSchedules {

    weak var readloggdataDelegate: ReadLoggdata?
    private var schedulesasDict: [NSDictionary]?

    /// Function reads schedules from permanent store
    /// - returns : array of NSDictonarys, return might be nil if schedule is already in memory
    func readSchedulesFromPermanentStore() -> [NSDictionary]? {
        return self.schedulesasDict
    }

    // Saving Schedules from MEMORY to persistent store
    func savescheduleInMemoryToPersistentStore() {
        var array = Array<NSDictionary>()
        // Reading Schedules from memory
        if let schedules = self.schedulesDelegate?.getschedulesobject()?.getSchedule() {
            for i in 0 ..< schedules.count {
                let schedule = schedules[i]
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
    }

    // Saving not deleted schedule records to persistent store
    // Deleted Schedule by hiddenID
    func savescheduleDeletedRecordsToFile (_ hiddenID: Int) {
        var array = Array<NSDictionary>()
        let Schedule = self.schedules!.getSchedule()
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
        if self.writeDatatoPersistentStorage(array, task: .schedule) {
            self.schedulesDelegate?.reloadschedules()
            self.readloggdataDelegate?.readloggdata()
        }
    }

    init (profile: String?) {
        super.init(task: .schedule, profile: profile)
        self.readloggdataDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
        if self.schedules == nil {
            self.schedulesasDict = self.getDatafromfile()
        }
    }
}

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
//   swiftlint:disable line_length

import Foundation

final class PersistentStorageScheduling: ReadWriteDictionary, SetSchedules {

    weak var readloggdataDelegate: ReadLoggdata?
    var schedulesasdictionary: [NSDictionary]?

    // Saving Schedules from MEMORY to persistent store
    func savescheduleInMemoryToPersistentStore() {
        var array = [NSDictionary]()
        // Reading Schedules from memory
        if let schedules = self.schedulesDelegate?.getschedulesobject()?.getSchedule() {
            for i in 0 ..< schedules.count {
                let schedule = schedules[i]
                let dict: NSMutableDictionary = [
                    "hiddenID": schedule.hiddenID,
                    "dateStart": schedule.dateStart,
                    "schedule": schedule.schedule,
                    "executed": schedule.logrecords,
                    "offsiteserver": schedule.offsiteserver ?? "localhost"]
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
            self.writeToStore(array: array)
        }
    }

    // Writing schedules to persistent store
    // Schedule is [NSDictionary]
    private func writeToStore(array: [NSDictionary]) {
        if self.writeNSDictionaryToPersistentStorage(array) {
            self.schedulesDelegate?.reloadschedulesobject()
            self.readloggdataDelegate?.readloggdata()
        }
    }

    init (profile: String?) {
        super.init(whattoreadwrite: .schedule, profile: profile, configpath: ViewControllerReference.shared.configpath)
        self.readloggdataDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
        if self.schedules == nil {
            self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
        }
    }

    init (profile: String?, allprofiles: Bool) {
        super.init(whattoreadwrite: .schedule, profile: profile, configpath: ViewControllerReference.shared.configpath)
        self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
    }
}

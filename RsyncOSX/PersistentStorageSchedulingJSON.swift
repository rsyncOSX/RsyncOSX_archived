//
//  PersistentStorageSchedulingJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

class PersistentStorageSchedulingJSON: PersistentStorageScheduling {
    // Saving Schedules from MEMORY to persistent store
    override func savescheduleInMemoryToPersistentStore() {
        if let schedules = self.schedules?.getSchedule() {
            let cleanedschedules = ConvertSchedules(schedules: schedules).cleanedschedules
            self.writeToStore(schedules: cleanedschedules)
        }
    }

    // Writing schedules to persistent store
    // Schedule is [NSDictionary]
    private func writeToStore(schedules: [ConfigurationSchedule]?) {
        let store = ReadWriteSchedulesJSON(schedules: schedules, profile: self.profile)
        store.writeJSONToPersistentStore()
        self.schedulesDelegate?.reloadschedulesobject()
    }
}

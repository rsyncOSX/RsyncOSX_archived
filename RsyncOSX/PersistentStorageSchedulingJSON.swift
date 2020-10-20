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
            self.writeToStore(schedules: schedules)
        }
    }

    // Writing schedules to persistent store
    // Schedule is [NSDictionary]
    private func writeToStore(schedules _: [ConfigurationSchedule]?) {
        let store = ReadWriteSchedulesJSON(schedules: schedules?.schedules, profile: self.profile)
        store.writeJSONToPersistentStore()
    }
}

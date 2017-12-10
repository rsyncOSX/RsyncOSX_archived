//
//  persistentStoreAPI.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//

import Foundation

final class PersistentStorageAPI: SetConfigurations, SetSchedules {

    var profile: String?

    // CONFIGURATIONS

    // Read configurations from persisten store
    func getConfigurations() -> [Configuration]? {
        let read = PersistentStorageConfiguration(profile: self.profile)
        // Either read from persistent store or
        // return Configurations already in memory
        if read.readConfigurationsFromPermanentStore() != nil {
            var Configurations = [Configuration]()
            for dict in read.readConfigurationsFromPermanentStore()! {
                let conf = Configuration(dictionary: dict)
                Configurations.append(conf)
            }
            return Configurations
        } else {
            return nil
        }
    }

    // Saving configuration from memory to persistent store
    func saveConfigFromMemory() {
        let save = PersistentStorageConfiguration(profile: self.profile)
        save.saveconfigInMemoryToPersistentStore()
    }

    // Saving added configuration
    func addandsaveNewConfigurations(dict: NSMutableDictionary) {
        let save = PersistentStorageConfiguration(profile: self.profile)
        save.newConfigurations(dict)
        save.saveconfigInMemoryToPersistentStore()
    }

    // SCHEDULE

    // Saving Schedules from memory to persistent store
    func saveScheduleFromMemory() {
        let store = PersistentStorageScheduling(profile: self.profile)
        store.savescheduleInMemoryToPersistentStore()
    }

    // Read schedules and history
    // If no Schedule from persistent store return nil
    func getScheduleandhistory () -> [ConfigurationSchedule]? {
        let read = PersistentStorageScheduling(profile: self.profile)
        var schedule = [ConfigurationSchedule]()
        // Either read from persistent store or
        // return Schedule already in memory
        if read.readSchedulesFromPermanentStore() != nil {
            for dict in read.readSchedulesFromPermanentStore()! {
                if let log = dict.value(forKey: "executed") {
                    let conf = ConfigurationSchedule(dictionary: dict, log: log as? NSArray)
                    schedule.append(conf)
                } else {
                    let conf = ConfigurationSchedule(dictionary: dict, log: nil)
                    schedule.append(conf)
                }
            }
            return schedule
        } else {
            return nil
        }
    }

    // Reading and writing scheduling data and results of executions.
    // StoreAPI : API to class persistentStorescheduling.
    // Readig schedules only (not sorted and expanden)
    // Sorted and expanded are only stored in memory
    func getScheduleonly () -> [ConfigurationSchedule] {
        let read = PersistentStorageScheduling(profile: self.profile)
        if read.readSchedulesFromPermanentStore() != nil {
            var schedule = [ConfigurationSchedule]()
            for dict in read.readSchedulesFromPermanentStore()! {
                let conf = ConfigurationSchedule(dictionary: dict, log: nil)
                schedule.append(conf)
            }
            return schedule
        } else {
            return []
        }
    }

    // USERCONFIG

    // Saving user configuration
    func saveUserconfiguration() {
        let store = PersistentStorageUserconfiguration(readfromstorage: false)
        store.saveUserconfiguration()
    }

    func getUserconfiguration (readfromstorage: Bool) -> [NSDictionary]? {
        let store = PersistentStorageUserconfiguration(readfromstorage: readfromstorage)
        return store.readUserconfigurationsFromPermanentStore()
    }

    init(profile: String?) {
        self.profile = profile
    }
}

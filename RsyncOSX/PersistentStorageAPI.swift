//
//  persistentStoreAPI.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//

import Foundation

class PersistentStorageAPI: SetConfigurations, SetSchedules {

    var profile: String?

    // CONFIGURATIONS
    // Read configurations from persisten store
    func getConfigurations() -> [Configuration]? {
        let read = PersistentStorageConfiguration(profile: self.profile)
        guard read.configurationsasdictionary != nil else { return nil}
        var Configurations = [Configuration]()
        for dict in read.configurationsasdictionary! {
            let conf = Configuration(dictionary: dict)
            Configurations.append(conf)
        }
        return Configurations
    }

    // Saving configuration from memory to persistent store
    func saveConfigFromMemory() {
        let save = PersistentStorageConfiguration(profile: self.profile)
        save.saveconfigInMemoryToPersistentStore()
    }

    // Saving added configuration
    func addandsaveNewConfigurations(dict: NSMutableDictionary) {
        let save = PersistentStorageConfiguration(profile: self.profile)
        save.newConfigurations(dict: dict)
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
    func getScheduleandhistory(nolog: Bool) -> [ConfigurationSchedule]? {
        let read = PersistentStorageScheduling(profile: self.profile)
        var schedule = [ConfigurationSchedule]()
        guard read.schedulesasdictionary != nil else { return nil }
        for dict in read.schedulesasdictionary! {
            if let log = dict.value(forKey: "executed") {
                let conf = ConfigurationSchedule(dictionary: dict, log: log as? NSArray, nolog: nolog)
                schedule.append(conf)
            } else {
                let conf = ConfigurationSchedule(dictionary: dict, log: nil, nolog: nolog)
                schedule.append(conf)
            }
        }
        return schedule
    }

    // USERCONFIG
    // Saving user configuration
    func saveUserconfiguration() {
        let store = PersistentStorageUserconfiguration(readfromstorage: false)
        store.saveUserconfiguration()
    }

    func getUserconfiguration (readfromstorage: Bool) -> [NSDictionary]? {
        let store = PersistentStorageUserconfiguration(readfromstorage: readfromstorage)
        return store.userconfiguration
    }

    init(profile: String?) {
        self.profile = profile
    }

}

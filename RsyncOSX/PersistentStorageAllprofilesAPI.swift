//
//  PersistentStorageAllprofilesAPI.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22/02/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

class PersistentStorageAllprofilesAPI: SetConfigurations, SetSchedules {
    var profile: String?

    // Configurations
    // Read configurations from persisten store
    func getConfigurations() -> [Configuration]? {
        if ViewControllerReference.shared.json {
            let read = PersistentStorageConfigurationJSON(profile: self.profile, allprofiles: true)
            return read.configurations
        } else {
            var Configurations = [Configuration]()
            let read = PersistentStorageConfiguration(profile: self.profile, allprofiles: true)
            guard read.configurationsasdictionary != nil else { return nil }
            for dict in read.configurationsasdictionary! {
                let conf = Configuration(dictionary: dict)
                Configurations.append(conf)
            }
            return Configurations
        }
    }

    // Schedules
    // If no Schedule from persistent store return nil
    func getScheduleandhistory(nolog: Bool) -> [ConfigurationSchedule]? {
        if ViewControllerReference.shared.json {
            let read = PersistentStorageSchedulingJSON(profile: self.profile, allprofiles: true)
            return read.schedules
        } else {
            var schedule = [ConfigurationSchedule]()
            let read = PersistentStorageScheduling(profile: self.profile, allprofiles: true)
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
    }

    init(profile: String?) {
        self.profile = profile
    }
}

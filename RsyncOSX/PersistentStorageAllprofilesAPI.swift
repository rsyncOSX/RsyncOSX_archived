//
//  PersistentStorageAllprofilesAPI.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22/02/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

class PersistentStorageAllprofilesAPI: PersistentStorageAPI {

    // CONFIGURATIONS
    // Read configurations from persisten store
    override func getConfigurations() -> [Configuration]? {
        let read = PersistentStorageConfiguration(profile: self.profile, allprofiles: true)
        guard read.configurationsasdictionary != nil else { return nil}
        var Configurations = [Configuration]()
        for dict in read.configurationsasdictionary! {
            let conf = Configuration(dictionary: dict)
            Configurations.append(conf)
        }
        return Configurations
    }

    // Read schedules and history
    // If no Schedule from persistent store return nil
    override func getScheduleandhistory(nolog: Bool) -> [ConfigurationSchedule]? {
        let read = PersistentStorageScheduling(profile: self.profile, allprofiles: true)
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

    override init(profile: String?) {
        super.init(profile: profile)
    }
}

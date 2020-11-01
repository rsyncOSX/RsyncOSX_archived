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

    func getConfigurations() -> [Configuration]? {
        var configurations = [Configuration]()
        if ViewControllerReference.shared.json {
            let read = PersistentStorageConfigurationJSON(profile: self.profile)
            let transform = TransformConfigfromJSON()
            for i in 0 ..< (read.decodedjson?.count ?? 0) {
                if let configitem = read.decodedjson?[i] as? DecodeConfigJSON {
                    let transformed = transform.transform(object: configitem)
                    if ViewControllerReference.shared.synctasks.contains(transformed.task) {
                        configurations.append(transformed)
                    }
                }
            }
        } else {
            let read = PersistentStorageConfiguration(profile: self.profile, readonly: true)
            guard read.configurationsasdictionary != nil else { return nil }
            for dict in read.configurationsasdictionary! {
                let conf = Configuration(dictionary: dict)
                configurations.append(conf)
            }
        }
        return configurations
    }

    func getScheduleandhistory(nolog: Bool) -> [ConfigurationSchedule]? {
        var schedule = [ConfigurationSchedule]()
        if ViewControllerReference.shared.json {
            let read = PersistentStorageSchedulingJSON(profile: self.profile)
            let transform = TransformSchedulefromJSON()
            for i in 0 ..< (read.decodedjson?.count ?? 0) {
                if let scheduleitem = (read.decodedjson?[i] as? DecodeScheduleJSON) {
                    var transformed = transform.transform(object: scheduleitem)
                    transformed.profilename = self.profile
                    schedule.append(transformed)
                }
            }
        } else {
            let read = PersistentStorageScheduling(profile: self.profile, readonly: true)
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
        }
        return schedule
    }

    init(profile: String?) {
        self.profile = profile
    }
}

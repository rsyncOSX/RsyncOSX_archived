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

    func getallconfigurations() -> [Configuration]? {
        var configurations = [Configuration]()
        if ViewControllerReference.shared.json {
            let read = PersistentStorageConfigurationJSON(profile: self.profile, readonly: true)
            let transform = TransformConfigfromJSON()
            for i in 0 ..< (read.decodedjson?.count ?? 0) {
                if let configitem = read.decodedjson?[i] as? DecodeConfiguration {
                    let transformed = transform.transform(object: configitem)
                    if ViewControllerReference.shared.synctasks.contains(transformed.task) {
                        configurations.append(transformed)
                    }
                }
            }
        } else {
            let read = PersistentStorageConfigurationPLIST(profile: self.profile, readonly: true)
            guard read.configurationsasdictionary != nil else { return nil }
            for dict in read.configurationsasdictionary! {
                let conf = Configuration(dictionary: dict)
                configurations.append(conf)
            }
        }
        return configurations
    }

    func getScheduleandhistory(includelog: Bool) -> [ConfigurationSchedule]? {
        var schedule = [ConfigurationSchedule]()
        if ViewControllerReference.shared.json {
            let read = PersistentStorageSchedulingJSON(profile: self.profile, readonly: true)
            let transform = TransformSchedulefromJSON()
            for i in 0 ..< (read.decodedjson?.count ?? 0) {
                if let scheduleitem = (read.decodedjson?[i] as? DecodeSchedule) {
                    var transformed = transform.transform(object: scheduleitem)
                    transformed.profilename = self.profile
                    schedule.append(transformed)
                }
            }
        } else {
            let read = PersistentStorageSchedulingPLIST(profile: self.profile, readonly: true)
            guard read.schedulesasdictionary != nil else { return nil }
            for dict in read.schedulesasdictionary! {
                if let log = dict.value(forKey: DictionaryStrings.executed.rawValue) {
                    let conf = ConfigurationSchedule(dictionary: dict, log: log as? NSArray, includelog: includelog)
                    schedule.append(conf)
                } else {
                    let conf = ConfigurationSchedule(dictionary: dict, log: nil, includelog: includelog)
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

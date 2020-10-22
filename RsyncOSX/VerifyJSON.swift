//
//  VerifyJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

class VerifyJSON {
    // Plist
    var plistconfigurations: [Configuration]?
    var plistschedules: [ConfigurationSchedule]?
    // JSON
    var jsonconfigurations: [DecodeConfigJSON]?
    var jsonschedules: [DecodeScheduleJSON]?

    var profile: String?

    func readschedulesplist() {
        let store = PersistentStorageScheduling(profile: self.profile, verify: true)
        self.plistschedules = store.getScheduleandhistory(nolog: false)
    }

    func readconfigurationsplist() {
        let store = PersistentStorageConfiguration(profile: self.profile, verify: true)
        self.plistconfigurations = store.readconfigurations()
    }

    func readschedulesJSON() {
        let store = ReadWriteSchedulesJSON(profile: self.profile)
        self.jsonschedules = store.decodedjson as? [DecodeScheduleJSON]
    }

    func readconfigurationsJSON() {
        let store = ReadWriteConfigurationsJSON(profile: self.profile)
        self.jsonconfigurations = store.decodedjson as? [DecodeConfigJSON]
    }

    init(profile: String?) {
        self.profile = profile
        self.readschedulesplist()
        self.readconfigurationsplist()
        self.readschedulesJSON()
        self.readconfigurationsJSON()
    }
}

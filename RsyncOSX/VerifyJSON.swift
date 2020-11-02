//
//  VerifyJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

class VerifyJSON {
    // Plist
    var plistconfigurations: [Configuration]?
    var plistschedules: [ConfigurationSchedule]?
    // JSON
    var jsonconfigurations: [DecodeConfigJSON]?
    var jsonschedules: [DecodeScheduleJSON]?
    var transformedconfigurations: [Configuration]?
    var transformedschedules: [ConfigurationSchedule]?
    var profile: String?
    // Result of verify
    var verifyconf: Bool?
    var verifysched: Bool?

    func readschedulesplist() {
        var store = PersistentStorageScheduling(profile: self.profile, readonly: true).getScheduleandhistory(nolog: false)
        var data = [ConfigurationSchedule]()
        for i in 0 ..< (store?.count ?? 0) where store?[i].logrecords.isEmpty == false || store?[i].dateStop != nil {
            store?[i].profilename = self.profile
            if let store = store?[i] {
                data.append(store)
            }
        }
        // Sorting schedule after hiddenID
        data.sort { (schedule1, schedule2) -> Bool in
            if schedule1.hiddenID > schedule2.hiddenID {
                return false
            } else {
                return true
            }
        }
        self.plistschedules = data
    }

    func readconfigurationsplist() {
        let store = PersistentStorageConfiguration(profile: self.profile, readonly: true).configurationsasdictionary
        var configurations = [Configuration]()
        for i in 0 ..< (store?.count ?? 0) {
            if let dict = store?[i] {
                let config = Configuration(dictionary: dict)
                if ViewControllerReference.shared.synctasks.contains(config.task) {
                    configurations.append(config)
                }
            }
        }
        self.plistconfigurations = configurations
    }

    func readschedulesJSON() {
        let store = PersistentStorageSchedulingJSON(profile: self.profile)
        self.jsonschedules = store.decodedjson as? [DecodeScheduleJSON]
        if let jsonschedules = self.jsonschedules {
            self.transformedschedules = [ConfigurationSchedule]()
            let transform = TransformSchedulefromJSON()
            for i in 0 ..< jsonschedules.count {
                var transformed = transform.transform(object: jsonschedules[i])
                transformed.profilename = self.profile
                self.transformedschedules?.append(transformed)
            }
        }
    }

    func readconfigurationsJSON() {
        let store = PersistentStorageConfigurationJSON(profile: self.profile)
        self.jsonconfigurations = store.decodedjson as? [DecodeConfigJSON]
        if let jsonconfigurations = self.jsonconfigurations {
            self.transformedconfigurations = [Configuration]()
            let transform = TransformConfigfromJSON()
            for i in 0 ..< jsonconfigurations.count {
                let transformed = transform.transform(object: jsonconfigurations[i])
                if ViewControllerReference.shared.synctasks.contains(transformed.task) {
                    self.transformedconfigurations?.append(transformed)
                }
            }
        }
    }

    func verifyconfigurations() {
        var verify: Bool = true
        self.verifyconf = verify
        if (self.plistconfigurations?.count ?? 0) == (self.transformedconfigurations?.count ?? 0) {
            if let plistconfigurations = self.plistconfigurations,
               let transformedconfigurations = self.transformedconfigurations
            {
                for i in 0 ..< plistconfigurations.count {
                    if Equal().isequalstructs(rhs: plistconfigurations[i], lhs: transformedconfigurations[i]) == false {
                        let errorstring = "Configurations in record: " + String(i) + ": not equal..."
                        self.error(str: errorstring)
                        verify = false
                        self.verifyconf = verify
                    }
                }
            }
        } else {
            self.error(str: "Configurations: not equal number of records.")
            verify = false
            self.verifyconf = verify
        }
        if verify {
            self.error(str: "...verify of Configurations seems OK...")
        }
    }

    func verifyschedules() {
        var verify: Bool = true
        self.verifysched = verify
        if (self.plistschedules?.count ?? 0) == (self.transformedschedules?.count ?? 0) {
            if let plistschedules = self.plistschedules,
               let transformedschedules = self.transformedschedules
            {
                for i in 0 ..< plistschedules.count {
                    if plistschedules[i].logrecords.count != transformedschedules[i].logrecords.count {
                        let errorstring = String(plistschedules[i].logrecords.count) + " in plist not equal in JSON " +
                            String(transformedschedules[i].logrecords.count)
                        self.error(str: errorstring)
                        verify = false
                        self.verifysched = verify
                    }
                    if Equal().isequalstructs(rhs: plistschedules[i], lhs: transformedschedules[i]) == false {
                        let errorstring = "Schedules in record: " + String(i) + ": not equal..."
                        self.error(str: errorstring)
                        verify = false
                        self.verifysched = verify
                    }
                }
            }
        } else {
            self.error(str: "Schedules: not equal number of records.")
            verify = false
            self.verifysched = verify
        }
        if verify {
            self.error(str: "...verify of Schedules seems OK...")
        }
    }

    func error(str: String) {
        let errormessage = OutputProcess()
        errormessage.addlinefromoutput(str: str)
        _ = Logging(errormessage, true)
    }

    init(profile: String?) {
        self.profile = profile
        self.readschedulesplist()
        self.readconfigurationsplist()
        self.readschedulesJSON()
        self.readconfigurationsJSON()
        self.verifyconfigurations()
        self.verifyschedules()
    }
}

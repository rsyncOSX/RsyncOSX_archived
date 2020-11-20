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
    var jsonconfigurations: [DecodeConfiguration]?
    var jsonschedules: [DecodeSchedule]?
    var transformedconfigurations: [Configuration]?
    var transformedschedules: [ConfigurationSchedule]?
    var profile: String?
    // Result of verify
    var verifyconf: Bool?
    var verifysched: Bool?
    // reload
    weak var reloadDelegate: Reloadandrefresh?
    // valid hiddenIDS
    var validplisthiddenID: Set<Int>?
    var validjsonhiddenID: Set<Int>?

    func readschedulesplist() {
        let store = PersistentStorageScheduling(profile: self.profile, readonly: true).schedulesasdictionary
        var schedules = [ConfigurationSchedule]()
        var schedule: ConfigurationSchedule?
        for i in 0 ..< (store?.count ?? 0) {
            if let dict = store?[i], let validplisthiddenID = self.validplisthiddenID {
                if let hiddenID = dict.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int {
                    if validplisthiddenID.contains(hiddenID) {
                        if let log = dict.value(forKey: DictionaryStrings.executed.rawValue) {
                            schedule = ConfigurationSchedule(dictionary: dict, log: log as? NSArray, includelog: true)
                        } else {
                            schedule = ConfigurationSchedule(dictionary: dict, log: nil, includelog: true)
                        }
                        schedule?.profilename = self.profile
                        if let conf = schedule { schedules.append(conf) }
                    }
                }
            }
        }
        // Sorting schedule after hiddenID
        schedules.sort { (schedule1, schedule2) -> Bool in
            if schedule1.hiddenID > schedule2.hiddenID {
                return false
            } else {
                return true
            }
        }
        self.plistschedules = schedules
    }

    func readschedulesJSON() {
        let store = PersistentStorageSchedulingJSON(profile: self.profile, readonly: true)
        self.jsonschedules = store.decodedjson as? [DecodeSchedule]
        if let jsonschedules = self.jsonschedules, let validjsonhiddenID = self.validjsonhiddenID {
            self.transformedschedules = [ConfigurationSchedule]()
            let transform = TransformSchedulefromJSON()
            for i in 0 ..< jsonschedules.count {
                var transformed = transform.transform(object: jsonschedules[i])
                transformed.profilename = self.profile
                if validjsonhiddenID.contains(transformed.hiddenID) {
                    self.transformedschedules?.append(transformed)
                }
            }
        }
    }

    func readconfigurationsplist() {
        let store = PersistentStorageConfiguration(profile: self.profile, readonly: true).configurationsasdictionary
        var configurations = [Configuration]()
        for i in 0 ..< (store?.count ?? 0) {
            if let dict = store?[i] {
                let config = Configuration(dictionary: dict)
                if ViewControllerReference.shared.synctasks.contains(config.task) {
                    configurations.append(config)
                    self.validplisthiddenID?.insert(config.hiddenID)
                }
            }
        }
        self.plistconfigurations = configurations
    }

    func readconfigurationsJSON() {
        let store = PersistentStorageConfigurationJSON(profile: self.profile, readonly: true)
        self.jsonconfigurations = store.decodedjson as? [DecodeConfiguration]
        if let jsonconfigurations = self.jsonconfigurations {
            self.transformedconfigurations = [Configuration]()
            let transform = TransformConfigfromJSON()
            for i in 0 ..< jsonconfigurations.count {
                let transformed = transform.transform(object: jsonconfigurations[i])
                if ViewControllerReference.shared.synctasks.contains(transformed.task) {
                    self.transformedconfigurations?.append(transformed)
                    self.validjsonhiddenID?.insert(transformed.hiddenID)
                }
            }
        }
    }

    func verifyconfigurations() {
        var verify: Bool = true
        self.verifyconf = verify
        guard (self.plistconfigurations?.count ?? 0) == (self.transformedconfigurations?.count ?? 0) else {
            let errorstring = "Configurations: not equal number of records." + "\n" + "Stopping further verify of Configurations..."
            self.error(str: errorstring)
            verify = false
            self.verifyconf = verify
            return
        }
        if let plistconfigurations = self.plistconfigurations,
           let transformedconfigurations = self.transformedconfigurations
        {
            for i in 0 ..< plistconfigurations.count {
                guard Equal().isequalstructs(rhs: plistconfigurations[i], lhs: transformedconfigurations[i]) == true else {
                    let errorstring = "Configurations in record " + String(i) + ": not equal..." + "\n" + "Stopping further verify of Configurations..."
                    self.error(str: errorstring)
                    verify = false
                    self.verifyconf = verify
                    return
                }
            }
        }
        if verify {
            self.error(str: "...verify of Configurations seems OK...")
        }
    }

    func verifyschedules() {
        var verify: Bool = true
        self.verifysched = verify
        guard (self.plistschedules?.count ?? 0) == (self.transformedschedules?.count ?? 0) else {
            let errorstring = "Schedules: not equal number of records." + "\n" + "Stopping further verify of Schedules..."
            self.error(str: errorstring)
            verify = false
            self.verifysched = verify
            return
        }
        if let plistschedules = self.plistschedules,
           let transformedschedules = self.transformedschedules
        {
            for i in 0 ..< plistschedules.count {
                guard plistschedules[i].logrecords?.count == transformedschedules[i].logrecords?.count else {
                    let errorstring = "Logrecord " + String(plistschedules[i].logrecords?.count ?? 0) + " in plist not equal in JSON " +
                        String(transformedschedules[i].logrecords?.count ?? 0) + "\n" + "Stopping further verify of Schedules..."
                    self.error(str: errorstring)
                    verify = false
                    self.verifysched = verify
                    return
                }
                guard Equal().isequalstructs(rhs: plistschedules[i], lhs: transformedschedules[i]) == true else {
                    let errorstring = "Schedules in record " + String(i) + ": not equal..." + "\n" + "Stopping further verify of Schedules..."
                    self.error(str: errorstring)
                    verify = false
                    self.verifysched = verify
                    return
                }
                for j in 0 ..< (plistschedules[i].logrecords?.count ?? 0) {
                    guard Equal().isequalstructs(rhs: plistschedules[i].logrecords?[j], lhs: transformedschedules[i].logrecords?[j]) == true else {
                        let errorstring = "Logrecord number " + String(j) + " in record " + String(i) + ": not equal..." + "\n" + "Stopping further verify of Schedules..."
                        self.error(str: errorstring)
                        verify = false
                        self.verifysched = verify
                        return
                    }
                }
            }
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
        self.validjsonhiddenID = Set()
        self.validplisthiddenID = Set()
        // Configurations
        self.readconfigurationsJSON()
        self.readconfigurationsplist()
        // Schedules
        self.readschedulesJSON()
        self.readschedulesplist()
        self.verifyconfigurations()
        self.verifyschedules()
        if let vc = ViewControllerReference.shared.getvcref(viewcontroller: .vcalloutput) as? ViewControllerAllOutput {
            self.reloadDelegate = vc
            self.reloadDelegate?.reloadtabledata()
        }
    }
}

//
//  VerifyJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity function_body_length trailing_comma

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

    func readschedulesplist() {
        let store = PersistentStorageScheduling(profile: self.profile, readorwrite: true)
        self.plistschedules = store.getScheduleandhistory(nolog: false)
    }

    func readconfigurationsplist() {
        let store = PersistentStorageConfiguration(profile: self.profile, readorwrite: true)
        self.plistconfigurations = store.readconfigurations()
    }

    func readschedulesJSON() {
        let store = ReadWriteSchedulesJSON(profile: self.profile)
        self.jsonschedules = store.decodedjson as? [DecodeScheduleJSON]
        if let jsonschedules = self.jsonschedules {
            self.transformedschedules = [ConfigurationSchedule]()
            for i in 0 ..< jsonschedules.count {
                var transformed = transformschedules(object: jsonschedules[i])
                transformed.profilename = self.profile
                self.transformedschedules?.append(transformed)
            }
        }
    }

    func readconfigurationsJSON() {
        let store = ReadWriteConfigurationsJSON(profile: self.profile)
        self.jsonconfigurations = store.decodedjson as? [DecodeConfigJSON]
        if let jsonconfigurations = self.jsonconfigurations {
            self.transformedconfigurations = [Configuration]()
            for i in 0 ..< jsonconfigurations.count {
                let transformed = transformconfigurations(object: jsonconfigurations[i])
                if ViewControllerReference.shared.synctasks.contains(transformed.task) {
                    self.transformedconfigurations?.append(transformed)
                }
            }
        }
    }

    func verifyconfigurations() {
        if (self.plistconfigurations?.count ?? 0) == (self.transformedconfigurations?.count ?? 0) {
            if let plistconfigurations = self.plistconfigurations,
               let transformedconfigurations = self.transformedconfigurations
            {
                for i in 0 ..< plistconfigurations.count {
                    if Equal().isequalstructs(rhs: plistconfigurations[i], lhs: transformedconfigurations[i]) == false {
                        let errorstring = "Configuartions in record: " + String(i) + ": not equal..."
                        self.error(str: errorstring)
                    }
                }
            }
        } else {
            self.error(str: "Configuartions: not equal number of records.")
        }
    }

    func verifyschedules() {
        if (self.plistschedules?.count ?? 0) == (self.transformedschedules?.count ?? 0) {
            if let plistschedules = self.plistschedules,
               let transformedschedules = self.transformedschedules
            {
                for i in 0 ..< plistschedules.count {
                    if plistschedules[i].logrecords.count != transformedschedules[i].logrecords.count {
                        let errorstring = String(plistschedules[i].logrecords.count) + " in plist not equal in JSON " +
                            String(transformedschedules[i].logrecords.count)
                        self.error(str: errorstring)
                    }
                    if Equal().isequalstructs(rhs: plistschedules[i], lhs: transformedschedules[i]) == false {
                        let errorstring = "Schedules in record: " + String(i) + ": not equal..."
                        self.error(str: errorstring)
                    }
                }
            }
        } else {
            self.error(str: "Schedules: not equal number of records.")
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

extension VerifyJSON {
    func transformschedules(object: DecodeScheduleJSON) -> ConfigurationSchedule {
        var log: [Any]?
        let dict: NSMutableDictionary = [
            "hiddenID": object.hiddenID ?? -1,
            "offsiteserver": object.offsiteserver ?? "",
            "dateStart": object.dateStart ?? "",
            "schedule": object.schedule ?? "",
            "profilename": object.profilename ?? "",
        ]
        if object.dateStop?.isEmpty == false {
            dict.setObject(object.dateStop ?? "", forKey: "dateStop" as NSCopying)
        }
        for i in 0 ..< (object.logrecords?.count ?? 0) {
            if i == 0 { log = Array() }
            let logdict: NSMutableDictionary = [
                "dateExecuted": object.logrecords![i].dateExecuted ?? "",
                "resultExecuted": object.logrecords![i].resultExecuted ?? "",
            ]
            log?.append(logdict)
        }
        return ConfigurationSchedule(dictionary: dict as NSDictionary, log: log as NSArray?, nolog: false)
    }

    func transformconfigurations(object: DecodeConfigJSON) -> Configuration {
        var dayssincelastbackup: String?
        var markdays: Bool = false
        var lastruninseconds: Double? {
            if let date = object.dateRun {
                let lastbackup = date.en_us_date_from_string()
                let seconds: TimeInterval = lastbackup.timeIntervalSinceNow
                return seconds * (-1)
            } else {
                return nil
            }
        }
        // Last run of task
        if object.dateRun != nil {
            if let secondssince = lastruninseconds {
                dayssincelastbackup = String(format: "%.2f", secondssince / (60 * 60 * 24))
                if secondssince / (60 * 60 * 24) > ViewControllerReference.shared.marknumberofdayssince {
                    markdays = true
                }
            }
        }
        let dict: NSMutableDictionary = [
            "localCatalog": object.localCatalog ?? "",
            "offsiteCatalog": object.offsiteCatalog ?? "",
            "parameter1": object.parameter1 ?? "",
            "parameter2": object.parameter2 ?? "",
            "parameter3": object.parameter3 ?? "",
            "parameter4": object.parameter4 ?? "",
            "parameter5": object.parameter5 ?? "",
            "parameter6": object.parameter6 ?? "",
            "task": object.task ?? "",
            "hiddenID": object.hiddenID ?? 0,
            "lastruninseconds": lastruninseconds ?? 0,
            "dayssincelastbackup": dayssincelastbackup ?? "",
            "markdays": markdays,
        ]
        if object.parameter8?.isEmpty == false {
            dict.setObject(object.parameter8 ?? "", forKey: "parameter8" as NSCopying)
        }
        if object.parameter9?.isEmpty == false {
            dict.setObject(object.parameter9 ?? "", forKey: "parameter9" as NSCopying)
        }
        if object.parameter10?.isEmpty == false {
            dict.setObject(object.parameter10 ?? "", forKey: "parameter10" as NSCopying)
        }
        if object.parameter11?.isEmpty == false {
            dict.setObject(object.parameter11 ?? "", forKey: "parameter11" as NSCopying)
        }
        if object.parameter12?.isEmpty == false {
            dict.setObject(object.parameter12 ?? "", forKey: "parameter12" as NSCopying)
        }
        if object.parameter13?.isEmpty == false {
            dict.setObject(object.parameter13 ?? "", forKey: "parameter13" as NSCopying)
        }
        if object.parameter14?.isEmpty == false {
            dict.setObject(object.parameter14 ?? "", forKey: "parameter14" as NSCopying)
        }
        if object.sshkeypathandidentityfile?.isEmpty == false {
            dict.setObject(object.sshkeypathandidentityfile ?? "", forKey: "sshkeypathandidentityfile" as NSCopying)
        }
        if object.pretask?.isEmpty == false {
            dict.setObject(object.pretask ?? "", forKey: "pretask" as NSCopying)
        }
        if object.posttask?.isEmpty == false {
            dict.setObject(object.posttask ?? "", forKey: "posttask" as NSCopying)
        }
        if object.executepretask != nil {
            dict.setObject(object.executepretask ?? 0, forKey: "executepretask" as NSCopying)
        }
        if object.executeposttask != nil {
            dict.setObject(object.executeposttask ?? 0, forKey: "executeposttask" as NSCopying)
        }
        if object.sshport != nil {
            dict.setObject(object.sshport ?? 22, forKey: "sshport" as NSCopying)
        }
        if object.rsyncdaemon != nil {
            dict.setObject(object.rsyncdaemon ?? 0, forKey: "rsyncdaemon" as NSCopying)
        }
        if object.haltshelltasksonerror != nil {
            dict.setObject(object.haltshelltasksonerror ?? 0, forKey: "haltshelltasksonerror" as NSCopying)
        }
        if object.dateRun?.isEmpty == false {
            dict.setObject(object.dateRun ?? "", forKey: "dateRun" as NSCopying)
        }
        if object.snapdayoffweek?.isEmpty == false {
            dict.setObject(object.snapdayoffweek ?? "", forKey: "snapdayoffweek" as NSCopying)
        }
        if object.snaplast != nil {
            dict.setObject(object.snaplast ?? 0, forKey: "snaplast" as NSCopying)
        }
        if object.snapshotnum != nil {
            dict.setObject(object.snapshotnum ?? 0, forKey: "snapshotnum" as NSCopying)
        }
        if object.backupID?.isEmpty == false {
            dict.setObject(object.backupID ?? "", forKey: "backupID" as NSCopying)
        }
        if object.offsiteServer?.isEmpty == false {
            dict.setObject(object.offsiteServer ?? "", forKey: "offsiteServer" as NSCopying)
        }
        if object.offsiteUsername?.isEmpty == false {
            dict.setObject(object.offsiteUsername ?? "", forKey: "offsiteUsername" as NSCopying)
        }
        return Configuration(dictionary: dict as NSDictionary)
    }
}

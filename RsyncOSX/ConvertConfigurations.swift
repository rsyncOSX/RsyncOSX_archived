//
//  ConvertConfigurations.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26/04/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity function_body_length trailing_comma

import Foundation

struct ConvertConfigurations: SetConfigurations {
    var configuration: NSMutableDictionary?

    private func checkparameter(param: String?) -> String? {
        if let parameter = param {
            guard parameter.isEmpty == false else { return nil }
            return parameter
        } else {
            return nil
        }
    }

    init(index: Int) {
        var config: Configuration = self.configurations!.getConfigurations()[index]
        let dict: NSMutableDictionary = [
            "task": config.task,
            "backupID": config.backupID,
            "localCatalog": config.localCatalog,
            "offsiteCatalog": config.offsiteCatalog,
            "offsiteServer": config.offsiteServer,
            "offsiteUsername": config.offsiteUsername,
            "parameter1": config.parameter1,
            "parameter2": config.parameter2,
            "parameter3": config.parameter3,
            "parameter4": config.parameter4,
            "parameter5": config.parameter5,
            "parameter6": config.parameter6,
            "dateRun": config.dateRun!,
            "hiddenID": config.hiddenID,
        ]
        // All parameters parameter8 - parameter14 are set
        config.parameter8 = self.checkparameter(param: config.parameter8)
        if config.parameter8 != nil {
            dict.setObject(config.parameter8!, forKey: "parameter8" as NSCopying)
        }
        config.parameter9 = self.checkparameter(param: config.parameter9)
        if config.parameter9 != nil {
            dict.setObject(config.parameter9!, forKey: "parameter9" as NSCopying)
        }
        config.parameter10 = self.checkparameter(param: config.parameter10)
        if config.parameter10 != nil {
            dict.setObject(config.parameter10!, forKey: "parameter10" as NSCopying)
        }
        config.parameter11 = self.checkparameter(param: config.parameter11)
        if config.parameter11 != nil {
            dict.setObject(config.parameter11!, forKey: "parameter11" as NSCopying)
        }
        config.parameter12 = self.checkparameter(param: config.parameter12)
        if config.parameter12 != nil {
            dict.setObject(config.parameter12!, forKey: "parameter12" as NSCopying)
        }
        config.parameter13 = self.checkparameter(param: config.parameter13)
        if config.parameter13 != nil {
            dict.setObject(config.parameter13!, forKey: "parameter13" as NSCopying)
        }
        config.parameter14 = self.checkparameter(param: config.parameter14)
        if config.parameter14 != nil {
            dict.setObject(config.parameter14!, forKey: "parameter14" as NSCopying)
        }
        if config.rsyncdaemon != nil {
            dict.setObject(config.rsyncdaemon!, forKey: "rsyncdaemon" as NSCopying)
        }
        if config.sshport != nil {
            dict.setObject(config.sshport!, forKey: "sshport" as NSCopying)
        }
        if config.snapshotnum != nil {
            dict.setObject(config.snapshotnum!, forKey: "snapshotnum" as NSCopying)
            if config.snaplast != nil {
                dict.setObject(config.snaplast!, forKey: "snaplast" as NSCopying)
            }
            if config.snapdayoffweek != nil {
                dict.setObject(config.snapdayoffweek!, forKey: "snapdayoffweek" as NSCopying)
            }
        }
        if config.sshkeypathandidentityfile != nil {
            dict.setObject(config.sshkeypathandidentityfile!, forKey: "sshkeypathandidentityfile" as NSCopying)
        }
        // Pre and post tasks
        if config.pretask != nil {
            dict.setObject(config.pretask!, forKey: "pretask" as NSCopying)
        }
        if config.executepretask != nil {
            dict.setObject(config.executepretask!, forKey: "executepretask" as NSCopying)
        }
        if config.posttask != nil {
            dict.setObject(config.posttask!, forKey: "posttask" as NSCopying)
        }
        if config.executeposttask != nil {
            dict.setObject(config.executeposttask!, forKey: "executeposttask" as NSCopying)
        }
        if config.haltshelltasksonerror != nil {
            dict.setObject(config.haltshelltasksonerror!, forKey: "haltshelltasksonerror" as NSCopying)
        }
        self.configuration = dict
    }
}

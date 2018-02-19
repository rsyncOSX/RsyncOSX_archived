//
//  PersistentStoreageUserconfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity function_body_length

import Foundation

final class PersistentStorageUserconfiguration: Readwritefiles, SetConfigurations {

    /// Variable holds all configuration data
    private var userconfiguration: [NSDictionary]?

    /// Function reads configurations from permanent store
    /// - returns : array of NSDictonarys, return might be nil
    func readUserconfigurationsFromPermanentStore() -> [NSDictionary]? {
        return self.userconfiguration
    }

    // Saving user configuration
    func saveUserconfiguration () {
        var version3Rsync: Int?
        var detailedlogging: Int?
        var executeinmenuapp: Int?
        var rsyncPath: String?
        var restorePath: String?
        var marknumberofdayssince: String?

        if ViewControllerReference.shared.rsyncVer3 {
            version3Rsync = 1
        } else {
            version3Rsync = 0
        }
        if ViewControllerReference.shared.detailedlogging {
            detailedlogging = 1
        } else {
            detailedlogging = 0
        }
        if ViewControllerReference.shared.rsyncPath != nil {
            rsyncPath = ViewControllerReference.shared.rsyncPath!
        }
        if ViewControllerReference.shared.restorePath != nil {
            restorePath = ViewControllerReference.shared.restorePath!
        }
        if ViewControllerReference.shared.executescheduledappsinmenuapp == true {
            executeinmenuapp = 1
        } else {
            executeinmenuapp = 0
        }

        var array = [NSDictionary]()
        marknumberofdayssince = String(ViewControllerReference.shared.marknumberofdayssince)
        let dict: NSMutableDictionary = [
            "version3Rsync": version3Rsync ?? 0 as Int,
            "detailedlogging": detailedlogging ?? 0 as Int,
            "marknumberofdayssince": marknumberofdayssince ?? "5.0",
            "executeinmenuapp": executeinmenuapp ?? 1 as Int]
        if rsyncPath != nil {
            dict.setObject(rsyncPath!, forKey: "rsyncPath" as NSCopying)
        }
        if restorePath != nil {
            dict.setObject(restorePath!, forKey: "restorePath" as NSCopying)
        }
        switch self.configurations!.operation {
        case .dispatch:
            dict.setObject("dispatch", forKey: "operation" as NSCopying)
        case .timer:
            dict.setObject("timer", forKey: "operation" as NSCopying)
        }
        if ViewControllerReference.shared.pathrsyncosx != nil {
            dict.setObject(ViewControllerReference.shared.pathrsyncosx!, forKey: "pathrsyncosx" as NSCopying)
        } else {
            dict.setObject("", forKey: "pathrsyncosx" as NSCopying)
        }
        if ViewControllerReference.shared.pathrsyncosxsched != nil {
            dict.setObject(ViewControllerReference.shared.pathrsyncosxsched!, forKey: "pathrsyncosxsched" as NSCopying)
        } else {
            dict.setObject("", forKey: "pathrsyncosxsched" as NSCopying)
        }
        array.append(dict)
        self.writeToStore(array)
    }

    // Writing configuration to persistent store
    // Configuration is [NSDictionary]
    private func writeToStore (_ array: [NSDictionary]) {
        // Getting the object just for the write method, no read from persistent store
        _ = self.writeDatatoPersistentStorage(array, task: .userconfig)
    }

    init (readfromstorage: Bool) {
        super.init(task: .userconfig, profile: nil)
        if readfromstorage {
            self.userconfiguration = self.getDatafromfile()
        }
    }
}
